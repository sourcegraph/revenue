import os
from pathlib import Path


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Application settings
    DEBUG = os.environ.get('FLASK_DEBUG', '0').lower() in ('1', 'true', 'on')
    TESTING = False
    
    # Database settings (for future use)
    DATABASE_URL = os.environ.get('DATABASE_URL') or 'sqlite:///pet_store.db'
    
    # API settings
    API_VERSION = 'v1'
    
    @staticmethod
    def init_app(app):
        pass


class DevelopmentConfig(Config):
    DEBUG = True
    DEVELOPMENT = True


class TestingConfig(Config):
    TESTING = True
    DEBUG = True
    DATABASE_URL = 'sqlite:///:memory:'


class ProductionConfig(Config):
    DEBUG = False
    
    @classmethod
    def init_app(cls, app):
        Config.init_app(app)


config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
