from flask import Blueprint, render_template, jsonifyjjj

bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    return jsonify({'message': 'Welcome to Flask Pet Store API'})


@bp.route('/health')
def health():
    return jsonify({'status': 'healthy'})

