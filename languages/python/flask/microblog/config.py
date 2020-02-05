import os

def raise_KeyError(msg=''): raise KeyError(msg)

class Config(object):
  SECRET_KEY = os.environ.get('SECRET_KEY') or raise_KeyError('Secret key is missing')
