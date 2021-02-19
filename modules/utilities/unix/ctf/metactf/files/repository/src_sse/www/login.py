#!/usr/bin/env python
import flask, flask.views
import os
from users import users

class Login(flask.views.MethodView):
    def get(self):
        return flask.render_template('login.html')

    def post(self):
        if 'logout' in flask.request.form:
            flask.session.pop('username', None)
            return flask.redirect(flask.url_for('main'))
        required = ['username', 'passwd']
        for r in required:
            if r not in flask.request.form:
                flask.flash("Error: {0} is required.".format(r))
                return flask.redirect(flask.url_for('main'))
        username = flask.request.form['username']
        passwd = flask.request.form['passwd']
        if username in users and users[username] == passwd:
            flask.session['username'] = username
            solveddir = "static/obj/" + flask.session['username'] + "/solved/"
            if not os.path.exists(solveddir):
                os.mkdir(solveddir)
        else:
            flask.flash("Username doesn't exist or incorrect password")
        return flask.redirect(flask.url_for('main'))
