import flask, flask.views
from utils import login_required
from users import users
import os
import time

class Score(flask.views.MethodView):
    @login_required
    def get(self):
        scores = {}
        account = flask.session['username']
        if account == 'admin':
            for user in users.keys():
                userdir = "static/obj/{}/solved/".format(user)
                if not os.path.exists(userdir):
                    os.mkdir(userdir)
                scores[user] = []
                for f in os.listdir(userdir):
                    if os.access(userdir+f,os.X_OK):
                        scores[user].append(f)
                scores[user].sort()
        else:
            userdir = "static/obj/{}/solved/".format(account)
            if not os.path.exists(userdir):
                os.mkdir(userdir)
            scores[account] = []
            for f in os.listdir(userdir):
                if os.access(userdir+f,os.X_OK):
                    scores[account].append(f)
            scores[account].sort()
        return flask.render_template('score.html', scores=scores, users=sorted(scores.keys()))
