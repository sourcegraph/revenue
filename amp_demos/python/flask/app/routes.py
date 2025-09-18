from flask import Blueprint, render_template, jsonify, request
from app.models import Pet

bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    return jsonify({'message': 'Welcome to Flask Pet Store API'})


@bp.route('/health')
def health():
    return jsonify({'status': 'healthy'})


@bp.route('/pets/generate')
def generate_pets():
    count = request.args.get('count', default=1, type=int)
    
    if count < 1:
        return jsonify({'error': 'Count must be a positive integer'}), 400
    
    if count > 100:
        return jsonify({'error': 'Count cannot exceed 100'}), 400
    
    pets = [Pet.generate_random().to_dict() for _ in range(count)]
    
    return jsonify({
        'pets': pets,
        'count': len(pets)
    })

