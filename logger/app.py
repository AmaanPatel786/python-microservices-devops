from flask import Flask, request, jsonify
import os, json
from datetime import datetime

app = Flask(__name__)

LOG_DIR = os.getenv("LOG_DIR","/logs")
LOG_FILE = os.path.join(LOG_DIR, "events.log")

os.makedirs(LOG_DIR, exist_ok=True)

@app.route("/health")
def health():
    return jsonify(status="ok")

@app.route("/log", methods=["POST"])
def log():
    try:
        data = request.get_json(force=True, silent=True) or {}
        data["ts"] = datetime.utcnow().isoformat()
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(data) + "\n")
        return jsonify(ok=True)
    except Exception as e:
        return jsonify(ok=False, error=str(e)), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9000)
