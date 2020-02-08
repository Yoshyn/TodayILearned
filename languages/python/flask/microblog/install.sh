# FROM https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install flask
pip install python-dotenv
pip install flask-wtf
pip install flask-sqlalchemy
pip install flask-migrate
pip install flask-shell-ipython

# flask db init
# flask db migrate -m "users table"
# flask db migrate -m "posts table"
# flask db upgrade # flask db downgrade #   Apply/remove to the DB
# flask run

# launch deactivate to quit the virtual env
# console + do import : dotenv run python
# console with flask loaded : flask shell
