from flask import Flask, render_template

app = Flask(__name__)


@app.route("/helloworld")
@app.route("/")
def index():
    return render_template("home.html", title='Hello')