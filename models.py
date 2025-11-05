from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, ForeignKey
from sqlalchemy.sql import func

# ✅ Just declare the database instance — don’t create app here
db = SQLAlchemy()


# ----------------------------------------------------------------------
# Contact Messages
# ----------------------------------------------------------------------
class ContactMessage(db.Model):
    __tablename__ = 'contact_messages'

    id = db.Column(db.Integer, primary_key=True)
    role = db.Column(db.Enum('vet','ngo','user', name='role_enum'), nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    subject = db.Column(db.String(100), nullable=False)
    message = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# ----------------------------------------------------------------------
# Diagnosis History
# ----------------------------------------------------------------------
class DiagnosisHistory(db.Model):
    __tablename__ = "diagnosis_history"
    id = db.Column(db.Integer, primary_key=True)
    pet_id = db.Column(db.Integer, db.ForeignKey("pet_records.id"))
    diagnosis = db.Column(db.Text)
    treatment = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# ----------------------------------------------------------------------
# Stray Cases -- user dashboard
class StrayCases(db.Model):
    __tablename__ = "stray_cases"
    case_id = db.Column(db.Integer, primary_key=True)
    ngo_id = db.Column(db.Integer, db.ForeignKey('ngo.id'), nullable=True)
    animal_type = db.Column(db.String(50), nullable=False, default='Unknown')
    description = db.Column(db.Text, nullable=True)
    location = db.Column(db.String(100), nullable=True)
    reported_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    image_path = db.Column(db.String(255), nullable=True)
    report_datetime = db.Column(db.DateTime, nullable=False, default=db.func.now())
    status = db.Column(db.Enum('Pending', 'In Progress', 'Resolved'), default='Pending')
    

    ngo = db.relationship('NGO', backref='stray_cases', lazy=True)
    reporter = db.relationship('User', backref='stray_cases', lazy=True)


class VetAppointment(db.Model):
    __tablename__ = "vet_appointments"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    pet_id = db.Column(db.Integer, nullable=True)
    vet_id = db.Column(db.Integer, db.ForeignKey("vets.id"), nullable=True)
    pet_name = db.Column(db.String(100), nullable=True)
    pet_type = db.Column(db.String(50), nullable=True)
    appointment_time = db.Column(db.DateTime, nullable=True)
    reason = db.Column(db.Text, nullable=True)
    status = db.Column(db.Enum('scheduled', 'cancelled', 'done', name='status_enum'),
                       nullable=False, default='scheduled')

    # Rename relationship to avoid conflict
    vet = db.relationship("Vet", backref="vet_appointments")  # <-- changed name

    def to_dict(self):
        return {
            "id": self.id,
            "pet_name": self.pet_name or "",
            "pet_type": self.pet_type or "",
            "date": self.appointment_time.date().isoformat() if self.appointment_time else "",
            "slot": self.appointment_time.strftime("%H:%M") if self.appointment_time else "",
            "status": self.status or "scheduled",
            "reason": self.reason or "",
        }


# ------------------------ Vets ------------------------
class Vet(db.Model, UserMixin):
    __tablename__ = "vets"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(15), nullable=False)
    specialization = db.Column(db.String(100))
    password = db.Column(db.String(200), nullable=False)
    clinic_address = db.Column(db.String(255))
    bio = db.Column(db.Text)
    created_at = db.Column(db.DateTime, server_default=func.now())
    updated_at = db.Column(db.DateTime, onupdate=func.now())

    # Explicit relationships to avoid backref conflicts
    appointments = db.relationship("Appointment", back_populates="vet")
    consultations = db.relationship("VetConsultation", back_populates="vet")
# ----------------------------------------------------------------------
# Users
# ----------------------------------------------------------------------
class User(db.Model, UserMixin):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    phone = db.Column(db.String(15), nullable=True)
    password = db.Column(db.String(255), nullable=False)
    role = db.Column(db.Enum("pet_owner", "vet", "ngo"), nullable=False)



# ----------------------------------------------------------------------
# Appointments from the vet dashboard
# ----------------------------------------------------------------------
# ------------------------ Appointments ------------------------
class Appointment(db.Model):
    __tablename__ = "appointments"
    
    id = db.Column(db.Integer, primary_key=True)
    vet_id = db.Column(db.Integer, db.ForeignKey('vets.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))  # owner
    pet_id = db.Column(db.Integer, db.ForeignKey('pet_records.id'))
    pet_name = db.Column(db.String(100))
    pet_type = db.Column(db.String(20))
    appointment_date = db.Column(db.Date)
    appointment_time = db.Column(db.Time)
    reason = db.Column(db.Text)
    status = db.Column(db.Enum('Pending','Approved','Rejected','Completed','Cancelled'), default='Pending')
    created_at = db.Column(db.TIMESTAMP, server_default=db.func.current_timestamp())

    # Relationships
    vet = db.relationship("Vet", back_populates="appointments")
    user = db.relationship("User", backref="appointments")
    pet = db.relationship("PetRecord", backref="appointments")

    def to_dict(self):
        return {
            "id": self.id,
            "pet_name": self.pet_name,
            "pet_type": self.pet_type,
            "date": self.appointment_date.strftime("%Y-%m-%d") if self.appointment_date else None,
            "slot": self.appointment_time.strftime("%H:%M:%S") if self.appointment_time else None,
            "status": self.status,
            "reason": self.reason
        }

# ----------------------------------------------------------------------
# Vet Consultations
# ----------------------------------------------------------------------
class VetConsultation(db.Model):
    __tablename__ = "vet_consultation"

    id = db.Column(db.Integer, primary_key=True)
    pet_id = db.Column(db.Integer, db.ForeignKey('pet_records.id'))
    pet_name = db.Column(db.String(100))
    pet_type = db.Column(db.String(50))
    notes = db.Column(db.Text)
    status = db.Column(db.String(50))
    vet_id = db.Column(db.Integer, db.ForeignKey('vets.id'))
    owner_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationships
    vet = db.relationship("Vet", back_populates="consultations")
    owner = db.relationship("User", backref="consultations")
    pet = db.relationship("PetRecord", backref="consultations")
# ----------------------------------------------------------------------
# Cases
# ----------------------------------------------------------------------
class Case(db.Model):
    __tablename__ = "cases"
    id = db.Column(db.Integer, primary_key=True)
    ngo_id = db.Column(db.Integer, db.ForeignKey("ngo.id"), nullable=False)
    animal_type = db.Column(db.String(50))
    location = db.Column(db.String(100))
    reported_by = db.Column(db.Integer)
    image_path = db.Column(db.String(255))
    status = db.Column(db.Enum("open", "resolved", "pending"), default="open")
    description = db.Column(db.Text)
    assigned_vet_id = db.Column(db.Integer, db.ForeignKey("vets.id"))


# ----------------------------------------------------------------------
# Pet Records
# ----------------------------------------------------------------------
class PetRecord(db.Model):
    __tablename__ = "pet_records"
    __table_args__ = {'extend_existing': True}  # <--- this allows redefinition

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    owner_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    pet_name = db.Column(db.String(100), nullable=False)
    pet_type = db.Column(db.String(50), nullable=False)
    species = db.Column(db.String(50), nullable=True)
    breed = db.Column(db.String(50), nullable=True)
    age = db.Column(db.Integer, nullable=True)
    gender = db.Column(db.String(10), nullable=True)
    dob = db.Column(db.Date, nullable=True)
    color = db.Column(db.String(50), nullable=True)
    vaccination_status = db.Column(db.String(50), nullable=True)
    medical_history = db.Column(db.Text, nullable=True)
    vet_id = db.Column(db.Integer, db.ForeignKey("vets.id"), nullable=True)
    photo_path = db.Column(db.String(255), nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    owner = db.relationship('User', backref='pets')

    def __repr__(self):
        return f"<PetRecord {self.pet_name} (ID: {self.id})>"


# ----------------------------------------------------------------------
# Consultation History
# ----------------------------------------------------------------------
class ConsultationHistory(db.Model):
    __tablename__ = 'consultation_history'
    id = db.Column(db.Integer, primary_key=True)
    vet_id = db.Column(db.Integer, db.ForeignKey('vets.id'), nullable=False)
    pet_id = db.Column(db.Integer, db.ForeignKey('pet_records.id'), nullable=False)
    diagnosis = db.Column(db.Text, nullable=False)
    treatment = db.Column(db.Text, nullable=False)
    visit_date = db.Column(db.Date, nullable=False)
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())

    # Relationships
    vet = db.relationship('Vet', backref='consultation_history')
    pet = db.relationship('PetRecord', backref='consultation_history')



# ----------------------------------------------------------------------
# Feedback
# ----------------------------------------------------------------------
class Feedback(db.Model):
    __tablename__ = "feedback"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    message = db.Column(db.Text, nullable=False)
    submitted_at = db.Column(db.DateTime, default=datetime.utcnow)


#-------------------------- NGO ------------------------
class NGO(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(10), nullable=False, default='ngo')  
    email = db.Column(db.String(100), nullable=False, unique=True)
    password = db.Column(db.String(200), nullable=False)
    phone = db.Column(db.String(20))
    address = db.Column(db.Text)
    location = db.Column(db.String(255))
    latitude = db.Column(db.Numeric(9,6))
    longitude = db.Column(db.Float)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    volunteers = db.relationship('Volunteer', backref='ngo', lazy=True)


class Volunteer(db.Model):
    __tablename__ = 'volunteers'  
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    phone = db.Column(db.String(15))
    area = db.Column(db.String(100))
    joined_date = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.Enum('active','inactive'), default='active')
    notes = db.Column(db.Text)
    ngo_id = db.Column(db.Integer, db.ForeignKey('ngo.id'))
    active = db.Column(db.Boolean, default=True)
