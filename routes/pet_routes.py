from flask import Blueprint, request, jsonify, session
from database.pet_utils import register_pet

pet_bp = Blueprint('pet_bp', __name__)

@pet_bp.route('/register_pet', methods=['POST'])
def register_pet_route():
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    pet_data = request.json
    user_id = session['user_id']
    
    register_pet(user_id, pet_data)
    return jsonify({'message': 'Pet registered successfully'})
