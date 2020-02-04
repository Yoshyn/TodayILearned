from flask import render_template
from app import app

@app.route('/')
@app.route('/index')
def index():
  binding = {'head_title': 'head_title', 'body_title': "body_title"}
  return render_template('index.html', binding = binding)
