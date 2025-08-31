from flask import Flask, render_template
import os, requests

app = Flask(__name__)

BACKEND_URL = os.getenv("BACKEND_URL","http://backend:5000/api/data")

@app.route("/")
def index():
    try:
        r = requests.get(BACKEND_URL, timeout=3)
        data = r.json()
    except Exception as e:
        data = {"error": str(e)}
    return render_template("index.html", data=data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
