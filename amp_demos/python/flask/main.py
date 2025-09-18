import os
from app import create_app
from config import config


def main():
    config_name = os.environ.get('FLASK_ENV', 'development')
    app = create_app(config[config_name])
    
    host = os.environ.get('FLASK_HOST', '127.0.0.1')
    port = int(os.environ.get('FLASK_PORT', 5000))
    debug = app.config.get('DEBUG', False)
    
    print(f"Starting Flask Pet Store API on http://{host}:{port}")
    app.run(host=host, port=port, debug=debug)


if __name__ == "__main__":
    main()
