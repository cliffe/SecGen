import flask, flask.views
from utils import login_required
import os
import zipfile, zlib

class Download(flask.views.MethodView):
    @login_required
    def get(self):
        binarydir = "static/obj/" + flask.session['username'] + "/"
        sets = [d for d in os.listdir(binarydir) if os.path.isdir(binarydir+d) and 'solved' not in d]
        return flask.render_template('download.html', sets=sorted(sets))

    @login_required
    def post(self):
        if 'logout' in flask.request.form:
            flask.session.pop('username', None)
            return flask.redirect(flask.url_for('login'))
        if 'setname' not in flask.request.form:
            flask.flash("Error: Must select a set to download")
            return flask.redirect(flask.url_for('download'))
        setname = flask.request.form['setname']
        userdir = "static/obj/" + flask.session['username'] + "/"
        setdir = userdir + setname + "/"
        setzipfilename = userdir + setname + ".zip"
        zf = zipfile.ZipFile(setzipfilename,'w')
        for bins in os.listdir(setdir):
            if not os.path.isdir(setdir+bins):
                zf.write(setdir+bins,compress_type=zipfile.ZIP_DEFLATED,arcname=bins)
        zf.close()
        return flask.send_file(setzipfilename,mimetype='application/zip',attachment_filename=setname+".zip",as_attachment=True)
#        solveddir = "static/obj/" + flask.session['username'] + "/solved/"
#        for bins in os.listdir(solveddir):
#            if not os.path.isdir(solveddir+bins):
#                zf.write(solveddir+bins,compress_type=zipfile.ZIP_DEFLATED,arcname=bins)
