#!/usr/bin/env python
import flask
import functools

def login_required(method):
    @functools.wraps(method)
    def wrapper(*args, **kwargs):
        if 'username' in flask.session:
            return method(*args, **kwargs)
        else:
            flask.flash("A login is required.")
            return flask.redirect(flask.url_for('login'))
    return wrapper
