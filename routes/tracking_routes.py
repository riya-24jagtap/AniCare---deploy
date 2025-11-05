from flask import Blueprint, request, jsonify, session
from database.tracking_utils import track_animal

tracking_bp = Blueprint('tracking_bp', __name__)

@tracking_bp.route('/track_animal', methods=['POST'])
def track_animal_route():
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    tracking_data = request.json
    user_id = session['user_id']
    
    track_animal(user_id, tracking_data)
    return jsonify({'message': 'Animal tracked successfully'})
