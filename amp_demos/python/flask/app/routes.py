from flask import Blueprint, render_template, jsonify, request

bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    return render_template('index.html')


@bp.route('/health')
def health():
    return jsonify({'status': 'healthy'})

