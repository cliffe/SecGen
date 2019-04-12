import flask, flask.views
from utils import login_required
from collections import OrderedDict
import os
import pexpect
import time

class Solve(flask.views.MethodView):
    @login_required
    def get(self):
        binarydir = "static/obj/{}/".format(flask.session['username'])
        sets = sorted([s for s in os.listdir(binarydir) if ('zip' not in s and 'solved' not in s)])
        d = OrderedDict()
        for s in sets:
            d[s] = sorted([f for f in os.listdir(binarydir+s) if (os.path.isfile(binarydir+s+'/'+f) and ('.' not in f))])
        return flask.render_template('solve.html', d=d)

    @login_required
    def post(self):
        if 'logout' in flask.request.form:
            flask.session.pop('username', None)
            return flask.redirect(flask.url_for('login'))
        if 'winput' not in flask.request.form:
            flask.flash("Error: Input is required.")
            return flask.redirect(flask.url_for('solve'))
        binarydir = "static/obj/{}/".format(flask.session['username'])
        problemset = (set([s for s in os.listdir(binarydir) if os.path.isdir(binarydir+s) and ('solved' not in s)]) & set(flask.request.form.keys()))
        if len(problemset) != 1:
            flask.flash("Error: No challenge selected.")
            return flask.redirect(flask.url_for('solve'))
        path = "static/obj/"
        logpath = "static/logs/"
        setname = problemset.pop()
        username = flask.session['username']
        program = flask.request.form[setname]
        winput = flask.request.form['winput']
        binarydir = "{}{}/{}/".format(path,username,setname)
        binarypath = binarydir + program
        bins = [f for f in os.listdir(binarydir) if os.path.isfile(binarydir+f)]
        if program not in bins:
            flask.flash("Invalid program binary: {}".format(binarypath))
            return flask.redirect(flask.url_for('solve'))
        child = pexpect.spawn(binarypath)
        child.expect('assword:.*')
        child.sendline(winput)
        child.expect('\n')
        child.expect(pexpect.EOF)
        if (child.before.find(b'Good') >= 0):
            flask.flash("Good Job.\nYou have solved " + program)
            if not os.path.exists(logpath):
                os.mkdir(logpath)
            logfilename = logpath + username + ".log"
            logfile = open(logfilename,"ab+")
            logentry = program + " " + winput + " : " + time.asctime() + " : " + flask.request.remote_addr + "\n"
            logfile.write(logentry.encode('utf-8'))
            logfile.close()
            os.rename(binarypath,path+username+"/solved/"+program)
        else:
            flask.flash("Try again.   "+ winput + " as the input to " + program + " is incorrect.")
        return flask.redirect(flask.url_for('solve'))
