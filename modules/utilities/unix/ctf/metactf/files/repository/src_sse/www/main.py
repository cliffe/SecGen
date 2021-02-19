import flask, flask.views
import os

class Main(flask.views.MethodView):
    def get(self, page="main"):
        page += ".html"
        if os.path.isfile('templates/' + page):
            return flask.render_template(page)
        return flask.abort(404)
