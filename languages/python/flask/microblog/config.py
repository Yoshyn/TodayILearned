import os

def raise_KeyError(msg=''): raise KeyError(msg)

base_dir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
  SECRET_KEY = os.environ.get('SECRET_KEY') or raise_KeyError('SECRET_KEY is missing')
  SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(base_dir, 'microblog.sqlite')
  SQLALCHEMY_TRACK_MODIFICATIONS = False # signal the app when change done in DB
