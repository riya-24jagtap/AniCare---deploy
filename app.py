from flask import Flask, render_template, request, redirect, session, url_for, flash, jsonify, current_app

from flask_login import LoginManager, login_user, logout_user, current_user, login_required
from datetime import datetime, timedelta, timezone, date, time, time as dt_time
from models import (
    db, Case, Volunteer, User, Vet, NGO,
    ConsultationHistory, Appointment, VetAppointment,
    PetRecord, VetConsultation, VetConsultation, StrayCases, PetRecord, ContactMessage, db
)
from sqlalchemy.exc import SQLAlchemyError
import traceback
import smtplib
from email.mime.text import MIMEText
from email.message import EmailMessage
from sqlalchemy import text, func
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from functools import wraps
import os
import mysql.connector
import math
from urllib.parse import urlparse
import tempfile
from flask_sqlalchemy import SQLAlchemy
import ssl

app = Flask(__name__, template_folder="templates")

# Secret key from environment variable
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "dev_fallback_key")

# ------------------- DATABASE SETUP -------------------
raw_db_url = os.environ.get("DATABASE_URL")
uri = urlparse(raw_db_url)

app.config['SQLALCHEMY_DATABASE_URI'] = (
    f"mysql+pymysql://{uri.username}:{uri.password}"
    f"@{uri.hostname}:{uri.port or 3306}/{uri.path.lstrip('/')}"
)

AIVEN_CA_PEM = os.environ.get("AIVEN_CA_PEM")

if AIVEN_CA_PEM:
    cert_file = tempfile.NamedTemporaryFile(delete=False, suffix=".pem")
    cert_file.write(AIVEN_CA_PEM.encode("utf-8"))
    cert_file.flush()

    app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
        "connect_args": {
            "ssl": {
                "ca": cert_file.name
            }
        }
    }
else:
    # Local fallback for development
    app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:root@localhost:3306/anicare_db"
    app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
        "pool_recycle": 280,
        "pool_pre_ping": True
    }

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize SQLAlchemy
db.init_app(app)

# ✅ TEMPORARY: Create tables on Render once
with app.app_context():
    try:
        db.create_all()
        print("✅ All tables created successfully!")
    except Exception as e:
        print("⚠️ Error creating tables:", e)


login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'



# ------------------- CASE STATUS -------------------
CASE_STATUS = {
    "REPORTED": "reported",
    "PENDING": "pending",
    "IN_PROGRESS": "in_progress",
    "RESOLVED": "resolved"
}
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


# ------------------- HELPERS -------------------
@login_manager.user_loader
def load_user(user_id):
    """Load user from any table based on ID."""
    try:
        user_id = int(user_id)
    except (TypeError, ValueError):
        return None

    # Try in unified users table
    user = User.query.get(user_id)
    if user:
        print(f"🔹 Loaded User: {user.email} ({user.role}) from users")
        return user

    # Try in vets table
    vet = Vet.query.get(user_id)
    if vet:
        print(f"🔹 Loaded Vet: {vet.email}")
        vet.role = "vet"
        return vet

    # Try in NGO table
    ngo = NGO.query.get(user_id)
    if ngo:
        print(f"🔹 Loaded NGO: {ngo.email}")
        ngo.role = "ngo"
        return ngo

    print(f"⚠️ No user found with id {user_id}")
    return None



def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="root",
        database="anicare_db",
        auth_plugin='mysql_native_password',
        autocommit=True
    )


# def role_required(role=None):
#     def decorator(f):
#         @wraps(f)
#         def wrapper(*args, **kwargs):
#             if not current_user.is_authenticated:
#                 flash("Please log in first.", "error")
#                 return redirect(url_for('login'))
#             if role and getattr(current_user, 'role', None) != role:
#                 flash(f"Unauthorized. Requires {role}.", "error")
#                 return redirect(url_for('login'))
#             return f(*args, **kwargs)
#         return wrapper
#     return decorator

@app.route("/check-db")
def check_db():
    try:
        tables = db.engine.table_names()
        return jsonify({"tables": tables})
    except Exception as e:
        return jsonify({"error": str(e)})

def role_required(required_role):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if not current_user.is_authenticated or session.get('role') != required_role:
                flash(f"You must be logged in as {required_role}.", "error")
                return redirect(url_for('login'))
            return f(*args, **kwargs)
        return wrapper
    return decorator


@app.route('/vet_login', methods=['POST'])
def vet_login():
    email = request.form.get('email')
    password = request.form.get('password')
    
    vet = Vet.query.filter_by(email=email).first()
    
    if vet and check_password_hash(vet.password, password):
        session['user_id'] = vet.id      # ✅ standard key
        session['role'] = 'vet'
        flash("Logged in successfully as vet", "success")
        return redirect(url_for('vet_dashboard'))
    
    flash("Invalid credentials", "error")
    return redirect(url_for('login'))


def haversine(lat1, lon1, lat2, lon2):
    # Convert all to float
    lat1 = float(lat1)
    lon1 = float(lon1)
    lat2 = float(lat2)
    lon2 = float(lon2)

    R = 6371  # km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    return R * c


def get_nearest_ngos(user_lat, user_lon, limit=5):
    ngos = db.session.execute(text("SELECT id, name, latitude, longitude FROM ngo")).mappings().fetchall()
    ngos_with_distance = []
    for ngo in ngos:
        if ngo['latitude'] is None or ngo['longitude'] is None:
            continue
        ngos_with_distance.append({**ngo, "distance_km": round(haversine(user_lat, user_lon, ngo['latitude'], ngo['longitude']),2)})
    ngos_with_distance.sort(key=lambda x: x['distance_km'])
    return ngos_with_distance[:limit]


# role select page
@app.route('/role_select')
def role_select():
    if 'user_id' not in session:
        flash("Please log in first.", "error")
        return redirect(url_for('login'))

    all_roles = ["pet_owner", "vet", "ngo"]
    current_role = session.get("role")

    return render_template(
        "role_select.html",
        user_roles=all_roles,
        current_role=current_role
    )


@app.route('/select_role/<role>')
def select_role(role):
    if 'user_id' not in session:
        flash("Please log in first.", "error")
        return redirect(url_for('login'))

    current_role = session.get('role')

    if role == current_role:
        # Redirect to the correct dashboard for the current role
        dashboard_routes = {
            'vet': 'vet_dashboard',
            'ngo': 'ngo_dashboard',
            'pet_owner': 'user_dashboard'  # correct endpoint name
        }
        return redirect(url_for(dashboard_routes[role]))
    else:
        # User clicked a different role → ask them to log in as that role
        flash(f"Please sign in as {role.replace('_', ' ').title()} to continue.", "error")
        return redirect(url_for('login'))




# ------------------- ROUTES -------------------

@app.route('/')
def home():
    return render_template('landing.html')

@app.route('/about')
def about():
    return render_template('about.html')

'''
def send_email_notification(full_name, sender_email, subject, role, message_body):
    try:
        msg = Message(
            subject=f"AniCare Contact Form: {subject}",
            recipients=['anicare.contactus@gmail.com'],
            body=(
                f"Name: {full_name}\n"
                f"Role: {role}\n"
                f"Email: {sender_email}\n\n"
                f"Message:\n{message_body}"
            )
        )
        mail.send(msg)
        print("✅ Email sent successfully!")
        return True

    except Exception as e:
        print("❌ Email failed to send:", str(e))
        return False
'''

ROLE_MAP = {
    'vet': 'vet',
    'ngo': 'ngo',
    'pet_owner': 'user'
}

# Show the Contact Us page
@app.route('/contact', methods=['GET'])
@login_required
def contact_page():
    return render_template('contact.html')


@app.route('/contact', methods=['GET', 'POST'])
@login_required  # remove this if you want contact page public
def contact():
    if request.method == 'GET':
        return render_template('contact.html')

    try:
        full_name = request.form.get('full_name')
        email = request.form.get('email')
        subject = request.form.get('subject')
        role = request.form.get('role')
        message_body = request.form.get('message')

        if not full_name or not email or not subject or not role or not message_body:
            return jsonify({'success': False, 'message': 'All fields are required.'})

        # ✅ Save message to DB
        contact_msg = ContactMessage(
            full_name=full_name,
            email=email,
            subject=subject,
            role='user' if role == 'pet_owner' else role,
            message=message_body,
            created_at=datetime.utcnow()
        )
        db.session.add(contact_msg)
        db.session.commit()

        # ❌ Email sending removed
        return jsonify({'success': True, 'message': 'Message received successfully!'})

    except Exception as e:
        print("Error saving contact message:", e)
        return jsonify({'success': False, 'message': 'Failed to submit message. Please try again.'})

         
from flask_login import login_required

@app.route('/feedback', methods=['GET', 'POST'])
def feedback():
    if request.method == 'POST':
        user_id = current_user.id if current_user.is_authenticated else None
        name = request.form.get('name')
        email = request.form.get('email')
        message = request.form.get('message')

        # Save to DB
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO feedback (user_id, name, email, message) VALUES (%s, %s, %s, %s)",
            (user_id, name, email, message)
        )
        conn.commit()
        cursor.close()
        conn.close()

        flash("Feedback submitted successfully!", "success")
        return redirect(url_for('feedback'))

    return render_template('feedback.html')




# ------------------- AUTH -------------------
@app.route('/logout')
def logout():
    logout_user()
    session.clear()  # Clears all session variables
    flash("Logged out successfully.", "info")
    return redirect(url_for('home'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        role = request.form.get('role')
        email = (request.form.get('email') or "").strip()
        password = request.form.get('password') or ""

        # Role-based lookup
        if role == 'vet':
            user = Vet.query.filter_by(email=email).first() or User.query.filter_by(email=email).first()
            user_role = "vet"
        elif role == 'ngo':
            user = NGO.query.filter_by(email=email).first() or User.query.filter_by(email=email).first()
            user_role = "ngo"
        else:
            user = User.query.filter_by(email=email).first() or Vet.query.filter_by(email=email).first() or NGO.query.filter_by(email=email).first()
            if isinstance(user, Vet): user_role = "vet"
            elif isinstance(user, NGO): user_role = "ngo"
            else: user_role = "pet_owner"

        if not user:
            flash("Invalid email or password", "error")
            return redirect(url_for('login'))

        try:
            valid = check_password_hash(user.password, password)
        except:
            valid = user.password == password

        if not valid:
            flash("Invalid email or password", "error")
            return redirect(url_for('login'))

        login_user(user)

        session['role'] = user_role
        session['user_id'] = user.id

        print(f"✅ Login success → {email} as {user_role}")

        if user_role == "vet":
            return redirect(url_for("vet_dashboard"))
        elif user_role == "ngo":
            return redirect(url_for("ngo_dashboard"))
        else:
            return redirect(url_for("user_dashboard"))

    return render_template("sign-in.html")

@app.route('/register', methods=['GET', 'POST'])

def register():
    if request.method == 'POST':
        role = request.form.get('role')
        if not role:
            flash("Please select a role", "error")
            return redirect(url_for('register'))

        email = request.form.get('email', '').strip()
        name = request.form.get('name', '').strip()
        phone = request.form.get('phone', '').strip()
        password = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')


        if not password or not confirm_password:
            flash("Password is required.", "error")
            return redirect(url_for('register'))

        hashed_password = generate_password_hash(password, method='pbkdf2:sha256', salt_length=8)

        try:
            # Check duplicate email
            if role == 'vet' and db.session.execute(text("SELECT * FROM vets WHERE email=:email"), {"email": email}).fetchone():
                flash("Email already registered as Vet.", "error")
                return redirect(url_for('register'))
            if role == 'ngo' and db.session.execute(text("SELECT * FROM ngo WHERE email=:email"), {"email": email}).fetchone():
                flash("Email already registered as NGO.", "error")
                return redirect(url_for('register'))
            if role == 'pet_owner' and db.session.execute(text("SELECT * FROM users WHERE email=:email"), {"email": email}).fetchone():
                flash("Email already registered as Pet Owner.", "error")
                return redirect(url_for('register'))

            # Insert based on role
            if role == 'vet':
                specialization = request.form.get('specialization', '').strip()
                clinic_address = request.form.get('clinic_address', '').strip()
                bio = request.form.get('bio', '').strip()

                new_vet = Vet(
                    name=name,
                    email=email,
                    phone=phone,
                    specialization=specialization,
                    clinic_address=clinic_address,
                    bio=bio,
                    password=hashed_password
                )
                db.session.add(new_vet)

            elif role == 'ngo':
                address = request.form.get('address', '').strip()
                location = request.form.get('location', '').strip()

                new_ngo = NGO(
                    name=name,
                    role=role,
                    email=email,
                    phone=phone,
                    address=address,
                    location=location,
                    password=hashed_password
                )
                db.session.add(new_ngo)

            else:
                new_user = User(
                    name=name,
                    email=email,
                    phone=phone,     # now this works
                    role=role,
                    password=hashed_password
                )
                db.session.add(new_user)
            db.session.commit()
            flash("Account created successfully!", "success")
            return redirect(url_for('login'))

        except Exception as e:
            db.session.rollback()
            flash(f"Registration failed: {str(e)}", "error")
            return redirect(url_for('register'))

    return render_template('register.html')


@app.route('/admin')
def admin_panel():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Fetch meaningful contact messages
    cursor.execute("""
        SELECT * FROM contact_messages
        WHERE message NOT IN ('hello world...', 'Testing contact page')
        ORDER BY created_at DESC
    """)
    contact_messages = cursor.fetchall()

    # Fetch meaningful feedback
    cursor.execute("""
        SELECT * FROM feedback
        WHERE message NOT IN ('hello world')
        ORDER BY submitted_at DESC
    """)
    feedbacks = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template(
        'admin_panel.html', 
        contact_messages=contact_messages, 
        feedbacks=feedbacks
    )
                           

# ------------------- FEEDBACK -------------------

@app.route('/submit_feedback', methods=['POST'])
def submit_feedback():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']
    message = request.form['message'].strip()
    submitted_at = datetime.now(timezone.utc)  # UTC time

    try:
        # Check for recent similar feedback
        time_threshold = submitted_at - timedelta(minutes=5)
        recent = db.session.execute(
            text("""
                SELECT * FROM feedback 
                WHERE user_id = :uid AND message = :msg AND submitted_at >= :threshold
            """),
            {"uid": user_id, "msg": message, "threshold": time_threshold}
        ).fetchone()

        if recent:
            flash("You've already submitted similar feedback recently.", "warning")
            return redirect(url_for('feedback'))

        # Insert new feedback
        db.session.execute(
            text("""
                INSERT INTO feedback (user_id, message, submitted_at)
                VALUES (:uid, :msg, :time)
            """),
            {"uid": user_id, "msg": message, "time": submitted_at}
        )
        db.session.commit()
        flash("Feedback submitted successfully!", "success")

    except Exception as e:
        db.session.rollback()
        flash(f"Error submitting feedback: {str(e)}", "error")

    return redirect(url_for('feedback'))

@app.route('/vet_dashboard')
@role_required('vet')
def vet_dashboard():
    vet_id = session.get('user_id')  # ✅ matches login
    vet = Vet.query.get(vet_id)

    if not vet:
        flash("Vet not found!", "error")
        return redirect(url_for('login'))

    appointments = VetAppointment.query.filter_by(vet_id=vet_id).order_by(
        VetAppointment.appointment_time
    ).all()

    return render_template('vet_dashboard.html', vet=vet, appointments=appointments)

@app.route('/vet_dashboard_data', methods=['GET'])
@role_required('vet')
def vet_dashboard_data():
    try:
        vet_id = session.get('user_id')
        if not vet_id:
            return jsonify({"success": False, "error": "Vet not logged in."}), 401

        all_appointments = []

        # Vet-created appointments (filtered by vet_id)
        try:
            vet_appts = VetAppointment.query.filter_by(vet_id=vet_id).all()
        except Exception as e:
            print("VetAppointment query error:", e)
            vet_appts = []

        for a in vet_appts:
            datetime_obj = getattr(a, "appointment_time", None)
            appt_date = datetime_obj.date() if datetime_obj else None
            appt_slot = datetime_obj.strftime("%I:%M %p") if datetime_obj else None
            status = (getattr(a, "status", "scheduled") or "scheduled").lower()
            if status == "scheduled":
                status = "pending"
            all_appointments.append({
                "id": getattr(a, "id", 0),
                "pet_name": getattr(a, "pet_name", ""),
                "pet_type": getattr(a, "pet_type", ""),
                "date": appt_date.strftime("%d %b %Y") if appt_date else "",
                "slot": appt_slot or "",
                "status": status,
                "reason": getattr(a, "reason", ""),
                "source": "vet"
            })

        # Owner-created appointments (also filtered by vet_id)
        try:
            owner_appts = Appointment.query.filter_by(vet_id=vet_id).all()
        except Exception as e:
            print("Appointment query error:", e)
            owner_appts = []

        for a in owner_appts:
            date_obj = getattr(a, "appointment_date", None)
            time_obj = getattr(a, "appointment_time", None)
            status = (getattr(a, "status", "pending") or "pending").lower()
            if status == "scheduled":
                status = "pending"
            all_appointments.append({
                "id": getattr(a, "id", 0),
                "pet_name": getattr(a, "pet_name", ""),
                "pet_type": getattr(a, "pet_type", ""),
                "date": date_obj.strftime("%d %b %Y") if date_obj else "",
                "slot": time_obj.strftime("%I:%M %p") if time_obj else "",
                "status": status,
                "reason": getattr(a, "reason", ""),
                "source": "owner"
            })

        # Sort all appointments
        for a in all_appointments:
            try:
                dt_str = (a["date"] or "1900-01-01") + " " + (a["slot"] or "12:00 AM")
                a["datetime_obj"] = datetime.strptime(dt_str, "%d %b %Y %I:%M %p")
            except:
                a["datetime_obj"] = datetime.min
        all_appointments.sort(key=lambda x: x["datetime_obj"])
        for a in all_appointments:
            a.pop("datetime_obj", None)

        # Dashboard counts
        today_str = date.today().strftime("%d %b %Y")
        today_appointments = sum(
            1 for a in all_appointments
            if a["date"] == today_str and a["status"] not in ["cancelled", "done"]
        )

        open_cases = today_appointments
        consultations_count = VetConsultation.query.filter_by(vet_id=vet_id).count() if VetConsultation.query else 0

        profile = {"name": "Vet Dashboard"}

        return jsonify({
            "success": True,
            "today_appointments": today_appointments,
            "open_cases": open_cases,
            "consultations_count": consultations_count,
            "profile": profile,
            "appointments": all_appointments
        })

    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return jsonify({
            "success": False,
            "error": str(e),
            "today_appointments": 0,
            "open_cases": 0,
            "consultations_count": 0,
            "profile": {"name": "—"},
            "appointments": []
        }), 500

@app.route('/update_appointment_status', methods=['POST'])
@role_required('vet')
def update_appointment_status():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'No data provided'}), 400

        appt_id = data.get('appointment_id') or data.get('id')
        new_status = data.get('status', '').lower()

        if not appt_id or not new_status:
            return jsonify({'success': False, 'error': 'Missing parameters'}), 400

        vet_id = session.get('user_id')
        appt = VetAppointment.query.filter_by(id=appt_id, vet_id=vet_id).first()
        if not appt:
            appt = Appointment.query.filter_by(id=appt_id, vet_id=vet_id).first()  # fallback
            if not appt:
                return jsonify({'success': False, 'error': 'Appointment not found'}), 404

        # Ensure allowed status
        allowed_statuses = ['pending', 'done', 'completed', 'cancelled', 'rejected']
        if new_status not in allowed_statuses:
            return jsonify({'success': False, 'error': f'Invalid status: {new_status}'}), 400

        appt.status = new_status
        db.session.commit()

        return jsonify({'success': True, 'message': f'Appointment marked as {new_status}'})
    
    except Exception as e:
        db.session.rollback()
        print("Error updating appointment:", e)  # <-- very important for debugging
        return jsonify({'success': False, 'error': str(e)}), 500
    
    
@app.route('/user_appointments')
@role_required('pet_owner')
def user_appointments():
    import traceback
    from sqlalchemy.exc import SQLAlchemyError

    user_id = session.get("user_id")
    print("\n🟢 [DEBUG] /user_appointments triggered for user_id:", user_id)

    if not user_id:
        print("❌ No user_id in session")
        return jsonify({"success": False, "error": "User not logged in", "appointments": []}), 401

    try:
        appointments = (
            db.session.query(Appointment, Vet.name.label("vet_name"))
            .outerjoin(Vet, Appointment.vet_id == Vet.id)
            .filter(Appointment.user_id == user_id)
            .order_by(Appointment.appointment_date.desc(), Appointment.appointment_time.asc())
            .all()
        )

        print(f"✅ Found {len(appointments)} appointments for user {user_id}")

        result = []
        for a, vet_name in appointments:
            print(f"   - Appointment ID: {a.id}, Vet: {vet_name}, Pet: {a.pet_name}, Status: {a.status}")
            result.append({
                "pet_name": a.pet_name or "-",
                "vet_name": vet_name or "-",
                "date": a.appointment_date.strftime("%Y-%m-%d") if a.appointment_date else "-",
                "slot": a.appointment_time.strftime("%H:%M") if a.appointment_time else "-",
                "reason": a.reason or "-",
                "status": a.status or "Pending"
            })

        return jsonify({"success": True, "appointments": result})

    except SQLAlchemyError as e:
        db.session.rollback()
        print("❌ SQLAlchemyError occurred:", e)
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e), "appointments": []}), 500

    except Exception as e:
        print("❌ General Exception:", e)
        traceback.print_exc()
        return jsonify({"success": False, "error": str(e), "appointments": []}), 500

@app.route('/get_all_owners')
def get_all_owners():
    owners = User.query.filter_by(role='pet_owner').all()
    return jsonify([{'id': o.id, 'name': o.name} for o in owners])

@app.route('/vet_appointments', methods=['GET'])
@role_required('vet')
def vet_appointments():
    vet_id = session.get("vet_id")
    if not vet_id:
        return jsonify({"success": False, "error": "Unauthorized"}), 401

    appts = db.session.execute(
        text("""
            SELECT a.id, a.pet_name, a.pet_type, a.appointment_date AS date,
                   a.appointment_time AS slot, a.reason, a.status,
                   u.name AS owner_name
            FROM appointments a
            LEFT JOIN users u ON a.user_id = u.id
            WHERE a.vet_id = :vet_id
            ORDER BY a.appointment_date DESC, a.appointment_time ASC
        """),
        {"vet_id": vet_id}
    ).mappings().all()

    formatted_appts = []
    for a in appts:
        # Format date as DD/MM/YYYY
        date_str = a['date'].strftime("%d/%m/%Y") if a['date'] else ""
        # Format time as HH:MM AM/PM
        slot_str = a['slot'].strftime("%I:%M %p") if isinstance(a['slot'], dt_time) else str(a['slot'])

        formatted_appts.append({
            "id": a['id'],
            "pet_name": a['pet_name'],
            "pet_type": a['pet_type'],
            "date": date_str,
            "slot": slot_str,
            "status": a['status'] or "",
            "owner_name": a['owner_name'] or ""
        })

    return jsonify({"success": True, "appointments": formatted_appts})

@app.route('/get_all_pets')
def get_all_pets():
    pets = PetRecord.query.join(User, PetRecord.owner_id == User.id) \
        .add_columns(
            PetRecord.id,
            PetRecord.pet_name,
            PetRecord.pet_type,
            User.name.label('owner_name'),
            User.id.label('owner_id')
        ).all()

    return jsonify([
        {
            'id': p.id,
            'name': p.pet_name,
            'type': p.pet_type,
            'owner_name': p.owner_name,
            'owner_id': p.owner_id
        } for p in pets
    ])



@app.route('/add_pet', methods=['POST'])
def add_pet():
    data = request.get_json()
    owner_id = data.get('owner_id')
    pet_name = data.get('pet_name')
    pet_type = data.get('pet_type')
    if not owner_id or not pet_name or not pet_type:
        return jsonify({"success": False, "error": "Missing fields"}), 400
    pet = PetRecord(owner_id=owner_id, pet_name=pet_name, pet_type=pet_type)
    db.session.add(pet)
    db.session.commit()
    return jsonify({"success": True, "pet": {"id": pet.id, "name": pet.pet_name, "type": pet.pet_type}})





# ------------------- Add Appointment -------------------
@app.route('/add_appointment', methods=['POST'])
def add_appointment():
    if not session.get("user_id") or session.get("role") != "vet":
        return jsonify({"success": False, "error": "Unauthorized"}), 401

    try:
        data = request.get_json() or {}
        vet_id = session.get("user_id")
        pet_name = data.get("pet_name")
        date_str = data.get("date")
        slot_str = data.get("slot")
        reason = data.get("reason", "")

        if not all([pet_name, date_str, slot_str]):
            return jsonify({"success": False, "error": "Missing required fields"}), 400

        # Parse datetime
        appt_datetime = datetime.strptime(f"{date_str} {slot_str}", "%Y-%m-%d %H:%M")

        # Check slot availability
        slots_data = get_vet_available_slots(vet_id, date_str)
        if slot_str not in slots_data['available']:
            return jsonify({"success": False, "error": "Slot is already booked"}), 400

        # Insert
        db.session.execute(
            text("""
                INSERT INTO appointments
                (vet_id, pet_name, appointment_time, reason, status)
                VALUES (:vet_id, :pet_name, :appt_time, :reason, 'Pending')
            """),
            {
                "vet_id": vet_id,
                "pet_name": pet_name,
                "appt_time": appt_datetime,
                "reason": reason
            }
        )
        db.session.commit()
        return jsonify({"success": True})

    except Exception as e:
        db.session.rollback()
        print(traceback.format_exc())
        return jsonify({"success": False, "error": str(e)}), 500




@app.route("/get_owner_pets/<int:owner_id>")
def get_owner_pets(owner_id):
    pets = PetRecord.query.filter_by(owner_id=owner_id).all()
    pet_list = [
        {"id": p.id, "name": p.pet_name, "type": p.pet_type} for p in pets
    ]
    return jsonify(pet_list)



# ------------------- Cancel Appointment -------------------
@app.route('/cancel_appointment', methods=['POST'])
def cancel_appointment():
    vet_id = session.get("user_id")
    if not vet_id or session.get('role') != 'vet':
        return jsonify({"success": False, "error": "Vet not logged in"}), 401

    data = request.get_json() or {}
    appt_id = data.get("id")
    if not appt_id:
        return jsonify({"success": False, "error": "No appointment ID provided"}), 400

    appt = VetAppointment.query.get(appt_id)
    if not appt:
        return jsonify({"success": False, "error": "Appointment not found"}), 404

    appt.status = 'done'  # or 'cancelled' if needed
    try:
        db.session.commit()
        return jsonify({"success": True})
    except Exception as e:
        db.session.rollback()
        return jsonify({"success": False, "error": str(e)}), 500
    
# ------------------- Add Consultation -------------------
# ------------------- Vet Consultations Data -------------------
@app.route('/add_consultation', methods=['POST'])
def add_consultation():
    if not session.get("user_id") or session.get("role") != "vet":
        return jsonify({"success": False, "error": "Unauthorized"}), 401

    try:
        data = request.get_json() or {}
        pet_id = data.get("pet_id")
        notes = data.get("notes")
        status = data.get("status", "pending")
        owner_id = data.get("owner_id")

        if not pet_id or not notes or not owner_id:
            return jsonify({"success": False, "error": "Missing required fields"}), 400

        # Fetch pet from DB
        pet = PetRecord.query.filter_by(id=pet_id).first()
        if not pet:
            return jsonify({"success": False, "error": "Pet not found"}), 404

        # Fetch owner from DB
        owner = User.query.filter_by(id=owner_id).first()

        consultation = VetConsultation(
            pet_id=pet.id,
            pet_name=pet.pet_name or "-",
            pet_type=pet.pet_type or "-",
            notes=notes,
            status=status,
            vet_id=session['user_id'],
            owner_id=owner_id,
            created_at=datetime.now()  # ensure timestamp
        )

        db.session.add(consultation)
        db.session.commit()

        result = {
            "pet_name": consultation.pet_name,
            "pet_type": consultation.pet_type,
            "notes": consultation.notes,
            "status": consultation.status,
            "owner_id": consultation.owner_id,
            "owner_name": owner.name if owner else "-",
            "created_at": consultation.created_at.strftime("%Y-%m-%d %H:%M:%S")
        }

        return jsonify({"success": True, "consultation": result})

    except Exception as e:
        db.session.rollback()
        print("Add consultation failed:", e)
        return jsonify({"success": False, "error": str(e)}), 500
    
# ------------------- Vet Consultations Data -------------------
@app.route('/vet_consultations_data', methods=['GET'])
def vet_consultations_data():
    try:
        consultations = VetConsultation.query.order_by(VetConsultation.created_at.desc()).all()
        result = [
            {
                "pet_name": c.pet_name,
                "pet_type": c.pet_type or '-',
                "notes": c.notes,
                "status": c.status,
                "created_at": c.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                "owner_name": c.owner.name if c.owner else "-"
            } for c in consultations
        ]
        return jsonify({"success": True, "consultations": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e), "consultations": []}), 500



# ------------------- User Consultations by Pet -------------------
@app.route('/user_consultations', methods=['GET'])
@role_required('pet_owner')
def user_consultations():
    owner_id = session.get('user_id')

    try:
        consultations = VetConsultation.query.filter_by(owner_id=owner_id) \
            .order_by(VetConsultation.created_at.desc()).all()

        result = [
            {
                "pet_name": c.pet_name,
                "pet_type": c.pet_type,
                "vet_name": c.vet.name if c.vet else "-",
                "notes": c.notes,
                "status": c.status,
                "created_at": c.created_at.strftime("%Y-%m-%d %H:%M:%S")
            } for c in consultations
        ]

        return jsonify({"success": True, "consultations": result})

    except Exception as e:
        app.logger.error("Error fetching user consultations: %s", e)
        return jsonify({"success": False, "consultations": [], "error": str(e)}), 500

@app.route('/user_consultations_data/<pet_name>', methods=['GET'])
@role_required('pet_owner')
def user_consultations_data(pet_name):
    owner_id = session.get('user_id')

    try:
        consultations = VetConsultation.query.filter_by(owner_id=owner_id, pet_name=pet_name) \
            .order_by(VetConsultation.created_at.desc()).all()

        data = [
            {
                "vet_name": c.vet.name if c.vet else "-",
                "notes": c.notes,
                "status": c.status,
                "created_at": c.created_at.strftime("%Y-%m-%d %H:%M:%S")
            } for c in consultations
        ]

        return jsonify({"success": True, "consultations": data})

    except Exception as e:
        app.logger.error("Error fetching consultations for pet '%s': %s", pet_name, e)
        return jsonify({"success": False, "consultations": [], "error": str(e)}), 500
# ------------------- Update Vet Profile -------------------
@app.route('/update_vet_profile', methods=['POST'])
@login_required
def update_vet_profile():
    vet_id = session.get('user_id')
    if not vet_id:
        flash("Please log in first!", "error")
        return redirect(url_for("login"))

    full_name = request.form.get("full_name", "").strip()
    email = request.form.get("email", "").strip()
    phone = request.form.get("phone", "").strip()
    specialization = request.form.get("specialization", "").strip()
    clinic_address = request.form.get("clinic_address", "").strip()
    bio = request.form.get("bio", "").strip()

    # Validation
    if not full_name or not email:
        flash("Name and Email are required.", "error")
        return redirect(url_for('vet_dashboard'))

    if phone and (not phone.isdigit() or len(phone) != 10):
        flash("Phone number must be 10 digits.", "error")
        return redirect(url_for('vet_dashboard'))

    try:
        # Use ORM to update
        vet = Vet.query.get(vet_id)
        if not vet:
            flash("Vet not found.", "error")
            return redirect(url_for('vet_dashboard'))

        vet.name = full_name
        vet.email = email
        vet.phone = phone
        vet.specialization = specialization
        vet.clinic_address = clinic_address
        vet.bio = bio
        vet.updated_at = datetime.utcnow()

        db.session.commit()
        flash("Profile updated successfully!", "success")
    except Exception as e:
        db.session.rollback()
        flash(f"Error updating profile: {str(e)}", "error")

    return redirect(url_for('vet_dashboard'))

@app.route('/mark_done_appointment', methods=['POST'])
def mark_done_appointment():
    try:
        data = request.get_json()
        if not data or "id" not in data:
            return jsonify({"success": False, "error": "No appointment ID provided"}), 400

        try:
            appt_id = int(data["id"])
        except ValueError:
            return jsonify({"success": False, "error": "Invalid appointment ID"}), 400

        # Fetch the appointment
        appt = VetAppointment.query.get(appt_id)
        if not appt:
            return jsonify({"success": False, "error": "Appointment not found"}), 404

        # Update status
        appt.status = "done"
        db.session.commit()

        return jsonify({"success": True})

    except Exception as e:
        # Log full error for debugging
        print("Error marking appointment done:", e)
        return jsonify({"success": False, "error": "Internal server error"}), 500



        
# ------------------- HELPER FUNCTIONS -------------------
def get_current_vet():
    vet_id = session.get("user_id")
    if not vet_id:
        return None
    return Vet.query.get(vet_id)

def get_upcoming_appointments(vet_id):
    return Appointment.query.filter_by(vet_id=vet_id).order_by(
        Appointment.appointment_date, Appointment.appointment_time
    ).all()


def get_consultations(vet_id):
    return db.session.execute(
        text("SELECT * FROM consultation_history WHERE vet_id = :vid"),
        {"vid": vet_id}
    ).mappings().all()


def count_open_cases(vet_id):
    return Appointment.query.filter_by(vet_id=vet_id).filter(
        Appointment.status.in_(["Pending", "Scheduled"])
    ).count()


# ------------------- USER (PET OWNER) DASHBOARD -------------------

# -----------------------------
# Helper Functions
# -----------------------------
def get_vet_slots_with_bookings(vet_id, date_str):
    try:
        vet = db.session.execute(
            text("SELECT working_start, working_end, slot_interval FROM vets WHERE id=:vid"),
            {"vid": vet_id}
        ).mappings().first()
        if not vet:
            return {"booked": [], "available": []}

        start_time = datetime.strptime(f"{date_str} {vet['working_start']}", "%Y-%m-%d %H:%M")
        end_time = datetime.strptime(f"{date_str} {vet['working_end']}", "%Y-%m-%d %H:%M")
        interval = int(vet['slot_interval'] or 30)

        # Fetch booked slots
        booked = db.session.execute(
            text("""
                SELECT TIME(appointment_time) as appt_time
                FROM vet_appointments
                WHERE vet_id=:vid AND DATE(appointment_time)=:date AND status='scheduled'
            """),
            {"vid": vet_id, "date": date_str}
        ).fetchall()
        booked_times = {row[0].strftime("%H:%M") for row in booked}

        # Generate all slots
        all_slots = []
        current = start_time
        while current + timedelta(minutes=interval) <= end_time:
            all_slots.append(current.strftime("%H:%M"))
            current += timedelta(minutes=interval)

        available_slots = [s for s in all_slots if s not in booked_times]

        return {"booked": list(booked_times), "available": available_slots}

    except Exception as e:
        app.logger.error(f"Error generating slots for vet {vet_id} on {date_str}: {e}")
        return {"booked": [], "available": []}
    
@app.route('/user_dashboard')
@role_required('pet_owner')
def user_dashboard():
    user_id = session.get('user_id')

    # Debug: Check if user_id is correctly retrieved from session
    print("DEBUG: session user_id =", user_id)

    # Fetch the pet owner name from the database
    user = User.query.get(user_id)
    if user:
        print("DEBUG: fetched user object =", user)
        user_name = user.name if user.name else "User"
    else:
        print("DEBUG: user not found in DB")
        user_name = "User"

    user_role = session.get('role', 'Pet Owner').replace('_', ' ').title()
    print("DEBUG: user_role =", user_role)

    try:
        # Fetch pets
        pets = db.session.execute(
            text("SELECT * FROM pet_records WHERE owner_id=:uid ORDER BY created_at DESC"),
            {"uid": user_id}
        ).mappings().all()

        # Fetch appointments with vet name
        appointments = db.session.execute(
            text("""
                SELECT a.pet_name, a.pet_type, v.name AS vet_name,
                       a.appointment_date AS date,
                       a.appointment_time AS slot,
                       a.reason, a.status
                FROM appointments a
                LEFT JOIN vets v ON a.vet_id = v.id
                WHERE a.user_id = :user_id
                ORDER BY a.appointment_date DESC, a.appointment_time ASC
            """),
            {"user_id": user_id}
        ).mappings().all()

        # Format appointment time
        formatted_appointments = []
        for appt in appointments:
            dt_time = appt['slot']
            slot = dt_time.strftime("%I:%M %p") if isinstance(dt_time, time) else str(dt_time)
            formatted_appointments.append({**appt, 'slot': slot})

    except Exception as e:
        app.logger.error(f"Error fetching dashboard data: {e}")
        flash("Failed to load dashboard. Please try again later.", "error")
        pets = []
        formatted_appointments = []

    return render_template(
        'user_dashboard.html',
        pets=pets,
        appointments=formatted_appointments,
        user_name=user_name,
        user_role=user_role
    )


    
@app.route('/go_to_dashboard/<role>')
def go_to_dashboard(role):
    if 'user_id' not in session:
        flash("Please log in first.", "error")
        return redirect(url_for('login'))

    # Only allow logged-in role to access their dashboard
    if session.get('role') != role:
        flash(f"You are logged in as {session.get('role')}. Please log out to switch roles.", "warning")
        return redirect(url_for('role_select'))

    dashboard_routes = {
    'vet': 'vet_dashboard',
    'ngo': 'ngo_dashboard',
    'pet_owner': 'user_dashboard'
}

    if role not in dashboard_routes:
        flash("Invalid role", "error")
        return redirect(url_for('role_select'))

    return redirect(url_for(dashboard_routes[role]))

@app.route('/dashboard_vet_schedule')
@role_required('pet_owner')
def dashboard_vet_schedule():
    # Get the requested date (default to today)
    date_str = request.args.get('date') or datetime.today().strftime('%Y-%m-%d')

    try:
        # Fetch all vets
        vets = db.session.execute(
            text("SELECT id, name, clinic_address FROM vets")
        ).mappings().all()

        vet_schedules = []

        for vet in vets:
            slots = get_vet_available_slots(vet['id'], date_str)
            vet_schedules.append({
                "id": vet['id'],
                "name": vet['name'],
                "clinic_address": vet['clinic_address'],
                "slots": slots
            })

        return jsonify({"date": date_str, "vet_schedules": vet_schedules})

    except Exception as e:
        app.logger.error(f"Error fetching vet schedules: {e}")
        return jsonify({"date": date_str, "vet_schedules": []})

@app.route('/pet_register', methods=['GET', 'POST'])
@role_required('pet_owner')
def pet_register():
    user_id = session['user_id']
    pet_id = request.args.get('pet_id', type=int)
    pet = None

    # Fetch all pets for this user
    pets = db.session.execute(
        text("SELECT * FROM pet_records WHERE owner_id=:uid ORDER BY id ASC"),
        {"uid": user_id}
    ).mappings().fetchall()

    vets = db.session.execute(text("SELECT id,name,clinic_address FROM vets")).mappings().fetchall()
    now = datetime.now()

    # If editing a specific pet
    if pet_id:
        pet = next((p for p in pets if p['id'] == pet_id), None)
        if not pet:
            if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                return jsonify({"success": False, "message": "Pet not found or permission denied."})
            flash("Pet not found or permission denied.", "error")
            return redirect(url_for('pet_register'))

    if request.method == 'POST':
        is_ajax = request.headers.get('X-Requested-With') == 'XMLHttpRequest'
        action = request.form.get('action')
        form_pet_id = request.form.get('pet_id')
        actual_pet_id = form_pet_id if form_pet_id and form_pet_id.strip() and form_pet_id != 'None' else pet_id

        # Fetch pet if needed
        if actual_pet_id and not pet:
            pet = db.session.execute(
                text("SELECT * FROM pet_records WHERE id=:pid AND owner_id=:uid"),
                {"pid": actual_pet_id, "uid": user_id}
            ).mappings().fetchone()
            pet_id = int(actual_pet_id) if actual_pet_id else None

        # Determine actual action
        actual_action = 'save' if pet and actual_pet_id else 'add'

        try:
            # ---------------- EDIT EXISTING PET ----------------
            if actual_action == 'save' and pet:
                pet_name = request.form.get('pet_name', '').strip()
                species = request.form.get('species', '').strip()
                other_species = request.form.get('other_species', '').strip()
                species = other_species if species == 'Other' and other_species else species
                breed = request.form.get('breed', '').strip()
                gender = request.form.get('gender', '').strip()
                dob = request.form.get('dob', None)
                color = request.form.get('color', '').strip()
                vaccination_status = request.form.get('vaccination_status', '')
                medical_history = request.form.get('medical_history', '').strip()
                vet_id = request.form.get('vet_id', type=int)

                # Calculate age
                age = None
                if dob:
                    birth_date = datetime.strptime(dob, '%Y-%m-%d').date()
                    today = date.today()
                    age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))

                # Handle photo
                pet_photo = request.files.get('photo')
                photo_path = pet['photo_path'] if pet and 'photo_path' in pet else None
                if pet_photo and pet_photo.filename != '':
                    os.makedirs('static/uploads', exist_ok=True)
                    filename = f"pet_{user_id}_{datetime.now().strftime('%Y%m%d%H%M%S')}_{secure_filename(pet_photo.filename)}"
                    pet_photo.save(os.path.join('static/uploads', filename))
                    photo_path = f"uploads/{filename}"

                # Update pet record
                db.session.execute(text("""
                    UPDATE pet_records
                    SET pet_name=:pet_name, species=:species, breed=:breed, gender=:gender,
                        age=:age, dob=:dob, color=:color, vaccination_status=:vaccination_status,
                        medical_history=:medical_history, vet_id=:vet_id, photo_path=:photo_path,
                        updated_at=CURRENT_TIMESTAMP
                    WHERE id=:pid AND owner_id=:uid
                """), {
                    "pet_name": pet_name,
                    "species": species,
                    "breed": breed,
                    "gender": gender,
                    "age": age,
                    "dob": dob,
                    "color": color,
                    "vaccination_status": vaccination_status,
                    "medical_history": medical_history,
                    "vet_id": vet_id,
                    "photo_path": photo_path,
                    "pid": pet_id,
                    "uid": user_id
                })

                # Handle AJAX response
                db.session.commit()
                if is_ajax:
                    return jsonify({"success": True, "message": "Pet details updated successfully!", "pet_id": pet_id})
                else:
                    flash("Pet details updated successfully!", "success")

            # ---------------- ADD NEW PET ----------------
            elif actual_action == 'add':
                pet_name = request.form.get('pet_name', '').strip()
                species = request.form.get('species', '').strip()
                other_species = request.form.get('other_species', '').strip()
                species = other_species if species == 'Other' and other_species else species
                breed = request.form.get('breed', '').strip()
                gender = request.form.get('gender', '').strip()
                dob = request.form.get('dob', None)
                color = request.form.get('color', '').strip()
                vaccination_status = request.form.get('vaccination_status', '')
                medical_history = request.form.get('medical_history', '').strip()
                vet_id = request.form.get('vet_id', type=int)

                age = None
                if dob:
                    birth_date = datetime.strptime(dob, '%Y-%m-%d').date()
                    today = date.today()
                    age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))

                # Photo
                pet_photo = request.files.get('photo')
                photo_path = None
                if pet_photo and pet_photo.filename != '':
                    os.makedirs('static/uploads', exist_ok=True)
                    filename = f"pet_{user_id}_{datetime.now().strftime('%Y%m%d%H%M%S')}_{secure_filename(pet_photo.filename)}"
                    pet_photo.save(os.path.join('static/uploads', filename))
                    photo_path = f"uploads/{filename}"

                if not pet_name:
                    error_message = "Pet name is required."
                    return jsonify({"success": False, "message": error_message}) if is_ajax else redirect(url_for('pet_register'))

                # Insert new pet
                db.session.execute(text("""
                    INSERT INTO pet_records (owner_id, pet_name, species, breed, gender, age, dob, color, 
                                             vaccination_status, medical_history, photo_path, vet_id)
                    VALUES (:owner_id, :pet_name, :species, :breed, :gender, :age, :dob, :color, 
                            :vaccination_status, :medical_history, :photo_path, :vet_id)
                """), {
                    "owner_id": user_id,
                    "pet_name": pet_name,
                    "species": species,
                    "breed": breed,
                    "gender": gender,
                    "age": age,
                    "dob": dob,
                    "color": color,
                    "vaccination_status": vaccination_status,
                    "medical_history": medical_history,
                    "photo_path": photo_path,
                    "vet_id": vet_id
                })
                db.session.commit()

                new_pet_id = db.session.execute(text("SELECT LAST_INSERT_ID() as id")).mappings().fetchone()['id']
                success_message = f"{pet_name} registered successfully!"
                if is_ajax:
                    return jsonify({"success": True, "message": success_message, "pet_id": new_pet_id})
                else:
                    flash(success_message, "success")
                    return redirect(url_for('pet_register', pet_id=new_pet_id))

        except Exception as e:
            db.session.rollback()
            error_message = f"Error saving pet: {str(e)}"
            if is_ajax:
                return jsonify({"success": False, "message": error_message})
            else:
                flash(error_message, "error")

    return render_template(
        'pet_register.html',
        pet=pet,
        pets=pets,         # pass pets here
        vets=vets,
        current_user=current_user,
        now=now
    )

from sqlalchemy import text

@app.route('/get_user_appointments')
def get_user_appointments():
    user_id = current_user.id  # the logged-in user's ID (vet or owner)

    appointments = db.session.execute(
        text("""
            SELECT va.id, va.pet_id, va.vet_id, va.reason, va.status,
                   p.pet_name, p.pet_type, v.name AS vet_name,
                   va.appointment_time
            FROM vet_appointments va
            JOIN pet_records p ON va.pet_id = p.id
            JOIN vets v ON va.vet_id = v.id
            WHERE va.vet_id = :vet_id
            ORDER BY va.appointment_time DESC
        """), 
        {'vet_id': user_id}
    ).mappings().fetchall()

    result = []
    for appt in appointments:
        result.append({
            'pet_name': appt['pet_name'],
            'pet_type': appt['pet_type'],
            'vet_name': appt['vet_name'],
            'date': appt['appointment_time'].strftime("%Y-%m-%d") if appt['appointment_time'] else "",
            'slot': appt['appointment_time'].strftime("%I:%M %p") if appt['appointment_time'] else "",
            'reason': appt['reason'],
            'status': appt['status']
        })

    return jsonify({'appointments': result})

@app.route('/get_pet_json')
@role_required('pet_owner')
def get_pet_json():
    user_id = session['user_id']
    pet_id = request.args.get('pet_id', type=int)
    if not pet_id:
        return jsonify({"success": False, "message": "Pet ID missing"})

    pet = db.session.execute(
        text("SELECT * FROM pet_records WHERE id=:pid AND owner_id=:uid"),
        {"pid": pet_id, "uid": user_id}
    ).mappings().fetchone()

    if not pet:
        return jsonify({"success": False, "message": "Pet not found"})

    # Convert DOB to string for input value
    pet_dict = dict(pet)
    pet_dict['dob'] = pet_dict['dob'].strftime('%Y-%m-%d') if pet_dict.get('dob') else ''

    return jsonify({"success": True, "pet": pet_dict})

# ---------------------
# Get Nearest NGOs
# ---------------------
def get_nearest_ngos(user_lat, user_lon, limit=5):
    """Return nearest NGOs with distance and address."""
    ngos = db.session.execute(
        text("SELECT id, name, latitude, longitude, location, address FROM ngo")
    ).mappings().fetchall()

    ngos_with_distance = []
    for ngo in ngos:
        if ngo['latitude'] is None or ngo['longitude'] is None:
            continue
        # Convert decimal.Decimal to float
        lat = float(ngo['latitude'])
        lon = float(ngo['longitude'])
        distance = haversine(user_lat, user_lon, lat, lon)
        ngos_with_distance.append({
            "id": ngo['id'],
            "name": ngo['name'],
            "location": ngo['location'],
            "address": ngo['address'],
            "distance_km": round(distance, 2)
        })

    ngos_with_distance.sort(key=lambda x: x['distance_km'])
    return ngos_with_distance[:limit]


# ---------------------
# Report Stray Route
# ---------------------
@app.route('/report_stray', methods=['GET', 'POST'])
def report_stray():
    user_id = session.get('user_id')
    role = session.get('role')

    if not user_id or role not in ['vet', 'pet_owner']:
        flash("You must be logged in as a vet or pet owner.", "error")
        return redirect(url_for('login'))

    form_data = {}
    nearest_ngos = []
    reports = []

    if request.method == "POST":
        form_data = request.form.to_dict()
        try:
            animal_type = form_data.get("animalType")
            description = form_data.get("description")
            location = form_data.get("location")
            ngo_id_raw = form_data.get("ngo_id")

            if not all([animal_type, description, location, ngo_id_raw]):
                flash("Please fill all required fields!", "error")
                return render_template("report_stray.html", form_data=form_data, reports=[], nearest_ngos=[])

            ngo_id = int(ngo_id_raw)

            # Handle optional photo upload
            image_filename = None
            photo = request.files.get("photo")
            if photo and photo.filename:
                os.makedirs("static/uploads", exist_ok=True)
                filename = secure_filename(photo.filename)
                photo.save(os.path.join("static/uploads", filename))
                image_filename = filename  # only save filename in DB

            # Insert into DB
            db.session.execute(
                text("""
                    INSERT INTO stray_cases
                    (reported_by, ngo_id, animal_type, description, location, image_path, status, report_datetime)
                    VALUES (:uid, :nid, :atype, :desc, :loc, :img, 'Pending', NOW())
                """),
                {
                    "uid": user_id,
                    "nid": ngo_id,
                    "atype": animal_type,
                    "desc": description,
                    "loc": location,
                    "img": image_filename
                }
            )
            db.session.commit()
            flash("Stray report submitted successfully!", "success")
            return redirect(url_for("report_stray"))

        except Exception as e:
            db.session.rollback()
            print("Insert failed:", e)
            flash(f"Failed to submit report: {str(e)}", "error")

    # Optional location handling
    user_lat = form_data.get("latitude") or request.args.get("latitude", type=float)
    user_lon = form_data.get("longitude") or request.args.get("longitude", type=float)
    if user_lat is not None and user_lon is not None:
        try:
            nearest_ngos = get_nearest_ngos(float(user_lat), float(user_lon), limit=5)
        except Exception as e:
            print("Error calculating nearest NGOs:", e)

    # Fetch user's reports
    try:
        reports = db.session.execute(
            text("""
                SELECT sc.case_id,
                    sc.animal_type,
                    sc.description,
                    sc.location,
                    sc.status,
                    sc.report_datetime,
                    sc.image_path,
                    n.name AS ngo_name,
                    u.name AS reporter_name
                FROM stray_cases sc
                LEFT JOIN ngo n ON sc.ngo_id = n.id
                LEFT JOIN users u ON sc.reported_by = u.id
                WHERE sc.reported_by = :uid
                ORDER BY sc.report_datetime DESC
            """),
            {"uid": user_id}
        ).mappings().all()


        # Build full URL for template
        for r in reports:
            r['photo_url'] = url_for('static', filename=f'uploads/{r["image_path"]}') if r['image_path'] else None

    except Exception as e:
        print("Failed to fetch reports:", e)
        flash("Failed to load submitted reports.", "error")

    return render_template(
        "report_stray.html",
        nearest_ngos=nearest_ngos,
        reports=reports,
        form_data=form_data
    )


# ---------------------
# Get Nearby NGOs (JSON)
# ---------------------
@app.route('/get_nearby', methods=['POST'])
def get_nearby():
    data = request.get_json(silent=True) or {}
    user_lat = data.get("latitude")
    user_lon = data.get("longitude")

    if user_lat is None or user_lon is None:
        return jsonify([])

    try:
        user_lat = float(user_lat)
        user_lon = float(user_lon)
    except ValueError:
        return jsonify([])

    nearest_ngos = get_nearest_ngos(user_lat, user_lon, limit=5)
    return jsonify(nearest_ngos)


# ---------------------
# Get User Reports (JSON)
# ---------------------
@app.route('/get_user_reports')
def get_user_reports():
    user_id = session.get('user_id')
    reports = db.session.execute(
        text("""
            SELECT sc.case_id, sc.animal_type, sc.description, sc.location, sc.status,
                   sc.report_datetime, n.name AS ngo_name
            FROM stray_cases sc
            LEFT JOIN ngo n ON sc.ngo_id = n.id
            WHERE sc.reported_by = :uid
            ORDER BY sc.report_datetime DESC
        """), {"uid": user_id}
    ).mappings().all()

    report_list = []
    for r in reports:
        report_list.append({
            "case_id": r['case_id'],
            "animal_type": r['animal_type'],
            "description": r['description'],
            "location": r['location'],
            "ngo_name": r['ngo_name'] or '-',
            "status": r['status'],
            "report_datetime": r['report_datetime'].strftime("%d-%m-%Y %H:%M")
        })
    return jsonify(report_list)
# ---------------------
# Role Required Decorator
# ---------------------
# def role_required(role):
#     def decorator(f):
#         @wraps(f)
#         def wrapped(*args, **kwargs):
#             if session.get('role') != role:
#                 flash("Unauthorized access", "error")
#                 return redirect(url_for('login'))
#             return f(*args, **kwargs)
#         return wrapped
#     return decorator



def get_vet_available_slots(vet_id, date_str):
    """
    Returns both booked and available slots for a given vet and date.
    Example:
    {
        "booked": ["10:00", "14:30"],
        "available": ["09:00", "09:30", "10:30", ...]
    }
    """
    # Define fixed working slots
    fixed_slots = [
        '09:00','09:30','10:00','10:30','11:00','11:30',
        '14:00','14:30','15:00','15:30','16:00','16:30','17:00','17:30'
    ]

    try:
        query = text("""
            SELECT TIME_FORMAT(appointment_time, '%H:%i') AS time
            FROM vet_appointments
            WHERE vet_id = :vet_id
              AND DATE(appointment_time) = :date
              AND status IN ('Pending','Approved','scheduled')
        """)
        results = db.session.execute(query, {'vet_id': vet_id, 'date': date_str}).fetchall()

        booked_slots = [row.time for row in results if row.time]
        available_slots = [slot for slot in fixed_slots if slot not in booked_slots]

        return {
            "booked": booked_slots,
            "available": available_slots
        }

    except Exception as e:
        app.logger.error(f"Error fetching slots: {e}")
        return {"booked": [], "available": fixed_slots}

# ---------------------
# Decorator
# ---------------------
# def role_required(role):
#     def decorator(f):
#         @wraps(f)
#         def wrapped(*args, **kwargs):
#             if session.get('role') != role:
#                 flash("Unauthorized access", "error")
#                 return redirect(url_for('login'))
#             return f(*args, **kwargs)
#         return wrapped
#     return decorator

@app.route('/get_fixed_slots')
def get_fixed_slots():
    try:
        slots = [
            "09:00", "09:30", "10:00", "10:30",
            "11:00", "11:30", "12:00", "12:30",
            "14:00", "14:30", "15:00", "15:30",
            "16:00", "16:30", "17:00"
        ]
        return jsonify({"success": True, "slots": slots})
    except Exception as e:
        app.logger.error(f"Error fetching fixed slots: {e}")
        return jsonify({"success": False, "slots": []}), 500

@app.route('/book_appointment', methods=['GET', 'POST'])
@role_required('pet_owner')
def book_appointment():
    # ------------------- Session Check -------------------
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('login'))

    # ------------------- POST: Booking an Appointment -------------------
    if request.method == 'POST':
        data = request.get_json()
        pet_id = data.get('pet_id')
        vet_id = data.get('vet_id')
        appointment_date_str = data.get('date')
        appointment_time_str = data.get('slot')
        reason = (data.get('reason') or '').strip()  # Always default to empty string

        try:
            # Convert date/time strings to objects
            appt_date_obj = datetime.strptime(appointment_date_str, "%Y-%m-%d").date()
            appt_time_obj = datetime.strptime(appointment_time_str, "%H:%M").time()

            # Prevent past dates
            today = date.today()
            if appt_date_obj < today:
                return jsonify({'success': False, 'error': 'Cannot book an appointment in the past.'}), 400

            # Prevent past times if today
            if appt_date_obj == today:
                current_time = datetime.now().time()
                if appt_time_obj <= current_time:
                    return jsonify({'success': False, 'error': 'Cannot book an appointment for a past time today.'}), 400

            # Check overlapping appointments
            overlapping = db.session.execute(
                text("""
                    SELECT 1 FROM appointments
                    WHERE vet_id=:vet_id AND appointment_date=:appt_date
                    AND appointment_time=:appt_time AND status='Pending'
                """),
                {"vet_id": vet_id, "appt_date": appointment_date_str, "appt_time": appointment_time_str}
            ).fetchone()
            if overlapping:
                return jsonify({'success': False, 'error': 'This slot is already booked.'}), 400

            # Fetch pet info
            pet = db.session.execute(
                text("""
                    SELECT pet_name, species AS pet_type
                    FROM pet_records
                    WHERE id=:pet_id AND owner_id=:owner_id
                """),
                {"pet_id": pet_id, "owner_id": user_id}
            ).mappings().first()
            if not pet:
                return jsonify({'success': False, 'error': 'Pet not found for this user.'}), 404

            # Fetch vet info
            vet = db.session.execute(
                text("SELECT name FROM vets WHERE id=:vet_id"),
                {"vet_id": vet_id}
            ).mappings().first()
            if not vet:
                return jsonify({'success': False, 'error': 'Vet not found.'}), 404

            # Insert appointment
            db.session.execute(
                text("""
                    INSERT INTO appointments
                    (vet_id, pet_id, user_id, pet_name, appointment_date, appointment_time, reason, status, pet_type)
                    VALUES (:vet_id, :pet_id, :user_id, :pet_name, :appt_date, :appt_time, :reason, 'Pending', :pet_type)
                """),
                {
                    "vet_id": vet_id,
                    "pet_id": pet_id,
                    "user_id": user_id,
                    "pet_name": pet['pet_name'],
                    "appt_date": appointment_date_str,
                    "appt_time": appointment_time_str,
                    "reason": reason,
                    "pet_type": pet['pet_type']
                }
            )
            db.session.commit()
            return jsonify({'success': True})

        except Exception as e:
            db.session.rollback()
            app.logger.error(f"Error booking appointment: {e}")
            return jsonify({'success': False, 'error': str(e)}), 500

    # ------------------- GET: Render Booking Page -------------------
    pets = db.session.execute(
        text("SELECT id, pet_name FROM pet_records WHERE owner_id=:owner_id"),
        {"owner_id": user_id}
    ).mappings().all()

    vets = db.session.execute(
        text("SELECT id, name, clinic_address FROM vets")
    ).mappings().all()

    appointments = db.session.execute(
        text("""
            SELECT a.pet_name, a.pet_type, v.name AS vet_name,
                   a.appointment_date AS appt_date,
                   a.appointment_time AS appt_time,
                   a.reason, a.status
            FROM appointments a
            LEFT JOIN vets v ON a.vet_id = v.id
            WHERE a.user_id=:user_id
            ORDER BY a.appointment_date DESC, a.appointment_time ASC
        """), {"user_id": user_id}
    ).mappings().all()

    # Format appointments
    formatted_appointments = []
    for appt in appointments:
        slot_time = appt['appt_time']
        slot_str = slot_time.strftime("%H:%M") if isinstance(slot_time, dt_time) else str(slot_time)
        appt_date_iso = appt['appt_date'].isoformat() if isinstance(appt['appt_date'], date) else str(appt['appt_date'])
        formatted_appointments.append({
            'pet_name': appt['pet_name'],
            'vet_name': appt['vet_name'],
            'pet_type': appt['pet_type'],
            'slot': slot_str,
            'date': appt_date_iso,
            'status': appt['status'],
            'reason': appt['reason'] or ''  # Ensure reason is never undefined
        })

    return render_template(
        'book_appointment.html',
        pets=pets,
        vets=vets,
        appointments=formatted_appointments,
        current_date=date.today().isoformat()
    )

FIXED_SLOTS = [
    '09:00','09:30','10:00','10:30','11:00','11:30',
    '14:00','14:30','15:00','15:30','16:00','16:30','17:00','17:30'
]

@app.route('/get_available_slots')
@role_required('pet_owner')
def get_available_slots():
    vet_id = request.args.get('vet_id')
    date_str = request.args.get('date')  # format: YYYY-MM-DD

    if not vet_id or not date_str:
        return jsonify({"booked": []}), 400

    try:
        # Parse date
        selected_date = datetime.strptime(date_str, "%Y-%m-%d").date()

        # Get all appointments for this vet and date
        appointments = db.session.execute(
            text("""SELECT appointment_time 
                    FROM appointments 
                    WHERE vet_id=:vet_id AND appointment_date=:appt_date"""),
            {"vet_id": vet_id, "appt_date": selected_date}
        ).fetchall()

        # Convert to list of strings "HH:MM"
        booked_slots = [appt[0].strftime("%H:%M") if isinstance(appt[0], dt_time) else str(appt[0]) for appt in appointments]

        return jsonify({"booked": booked_slots})

    except Exception as e:
        app.logger.error(f"Error fetching available slots: {e}")
        return jsonify({"booked": []}), 500

@app.route('/get_available_vets')
def get_available_vets():
    date_str = request.args.get('date')
    time_str = request.args.get('time')
    if not date_str or not time_str:
        return jsonify({"vets": []})

    try:
        chosen_dt = datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M")
    except ValueError:
        return jsonify({"vets": []})

    try:
        vets = db.session.execute(
            "SELECT id, name, clinic_address, working_start, working_end, slot_interval FROM vets WHERE clinic_address IS NOT NULL"
        ).mappings().all()

        available_vets = []

        for vet in vets:
            slot_interval = vet['slot_interval'] or 30
            working_start = datetime.strptime(f"{date_str} {vet['working_start']}", "%Y-%m-%d %H:%M")
            working_end = datetime.strptime(f"{date_str} {vet['working_end']}", "%Y-%m-%d %H:%M")
            slot_end = chosen_dt + timedelta(minutes=slot_interval)

            if chosen_dt < working_start or slot_end > working_end:
                continue

            overlapping = db.session.execute(
                text("""
                    SELECT 1
                    FROM appointments
                    WHERE vet_id = :vet_id
                      AND status = 'Pending'
                      AND appointment_time < :slot_end
                      AND (appointment_time + INTERVAL :interval_minute MINUTE) > :slot_start
                      AND appointment_date = :date
                    LIMIT 1
                """), {
                    "vet_id": vet['id'],
                    "slot_start": chosen_dt,
                    "slot_end": slot_end,
                    "interval_minute": slot_interval,
                    "date": date_str
                }
            ).fetchone()

            if not overlapping:
                available_vets.append({
                    "id": vet['id'],
                    "name": vet['name'],
                    "clinic_address": vet['clinic_address']
                })

        return jsonify({"vets": available_vets})

    except Exception as e:
        app.logger.error(f"Error fetching available vets: {e}")
        return jsonify({"vets": []})


@app.route('/consultation_history')
@role_required('pet_owner')
def consultation_history():
    user_id = session.get('user_id')

    try:
        consultations = VetConsultation.query.filter_by(owner_id=user_id)\
            .order_by(VetConsultation.created_at.desc()).all()

        # fallback if pet_type is missing
        for c in consultations:
            if not c.pet_type and c.pet:
                c.pet_type = c.pet.type
            if not c.pet_name and c.pet:
                c.pet_name = c.pet.name

    except Exception as e:
        app.logger.error("Error fetching consultation history: %s", e)
        flash("Could not load consultation history. Please try again later.", "error")
        consultations = []

    return render_template('consultation_history.html', consultations=consultations)

@app.route('/delete_pet/<int:pet_id>', methods=['POST'])
@role_required('pet_owner')
def delete_pet(pet_id):
    user_id = session['user_id']
    try:
        db.session.execute(
            text("DELETE FROM pet_records WHERE id=:pid AND owner_id=:uid"),
            {"pid": pet_id, "uid": user_id}
        )
        db.session.commit()
        flash("Pet deleted successfully!", "success")
    except Exception as e:
        db.session.rollback()
        flash(f"Error deleting pet: {str(e)}", "error")
    return redirect(url_for('user_dashboard'))

# ---------------------
# NGO Dashboard Page
# ---------------------
@app.route("/ngo_dashboard")
@login_required
def ngo_dashboard():
    if session.get('role') != 'ngo':
        flash("You must be logged in as an NGO.", "error")
        return redirect(url_for('login'))

    ngo_id = session.get('user_id')
    ngo = NGO.query.get(ngo_id)
    if not ngo:
        flash("NGO not found!", "error")
        return redirect(url_for('login'))

    # Fetch all cases assigned to this NGO
    cases = StrayCases.query.filter_by(ngo_id=ngo_id).all()

    cases_data = []
    for c in cases:
        # Fix for image path to avoid double 'uploads/' or missing image
        if c.image_path and c.image_path.strip():
            filename = c.image_path
            if filename.startswith('uploads/'):
                filename = filename[len('uploads/'):]  # Remove duplicate uploads/
            photo_url = url_for('static', filename=f'uploads/{filename}')
        else:
            photo_url = None  # No photo available

        cases_data.append({
            "id": c.case_id,
            "animal": c.animal_type,
            "desc": c.description,
            "photo_url": photo_url,
            "reporter": c.reporter.name if c.reporter else "Unknown",
            "status": c.status,
            "reportedAt": c.report_datetime.strftime("%d-%b-%Y, %I:%M %p") if c.report_datetime else "",
            "location": c.location or ""
        })

    ngo_info = {
        "name": ngo.name,
        "admin": ngo.name,
        "email": ngo.email,
        "contact": ngo.phone
    }

    return render_template(
        "ngo_dashboard.html",
        cases_data=cases_data,
        ngo_info=ngo_info
    )


@app.route("/ngo_dashboard_json")
@login_required
def ngo_dashboard_json():
    if session.get('role') != 'ngo':
        return jsonify([])

    cases = StrayCases.query.filter_by(ngo_id=current_user.id).all()

    cases_data = []
    for c in cases:
        if c.image_path and c.image_path.strip():
            # Avoid double 'uploads/' if already present
            filename = c.image_path
            if filename.startswith('uploads/'):
                filename = filename[len('uploads/'):]
            photo_url = url_for('static', filename=f'uploads/{filename}')
        else:
            photo_url = None  # No image available

        cases_data.append({
            "id": c.case_id,
            "animal": c.animal_type,
            "desc": c.description,
            "photo_url": photo_url,
            "reporter": c.reporter.name if c.reporter else "Unknown",
            "status": c.status,
            "reportedAt": c.report_datetime.strftime("%d-%b-%Y, %I:%M %p") if c.report_datetime else "",
            "location": c.location or ""
        })

    return jsonify(cases_data)


# ---------------------
# Update Case Status
# ---------------------
@app.route('/update_case_status', methods=['POST'])
def update_case_status():
    data = request.get_json()
    case_id = data.get('id')
    new_status = data.get('status')

    case = StrayCases.query.get(case_id)
    if case:
        case.status = new_status
        db.session.commit()
        return jsonify({'success': True})
    return jsonify({'success': False}), 400

# ------------------- MAIN -------------------

if __name__ == '__main__':
    app.run(debug=True)

with app.app_context():
    tables = db.session.execute(db.text("SHOW TABLES")).fetchall()
    print("Tables in DB:", tables)

