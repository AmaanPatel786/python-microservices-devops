from flask import Flask, jsonify, request
import os, time
import MySQLdb
import requests

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_PORT = int(os.getenv("DB_PORT", "3306"))   # ✅ MySQL default port
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "apppassword")
LOGGER_URL = os.getenv("LOGGER_URL", "http://logger:9000/log")

def get_conn():
    return MySQLdb.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        passwd=DB_PASSWORD,
        db=DB_NAME
    )

def init_db():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("""
            CREATE TABLE IF NOT EXISTS users(
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)
        conn.commit()

# Run DB init at startup
with app.app_context():
    for _ in range(20):
        try:
            init_db()
            break
        except Exception:
            time.sleep(1)

@app.route("/api/health")
def health():
    return jsonify(status="ok")

@app.route("/api/data")
def data():
    count = 0
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM users;")
                count = cur.fetchone()[0]
        db_ok = True
    except Exception:
        db_ok = False
    payload = {"message": "Hello from backend", "db_ok": db_ok, "user_count": count}
    try:
        requests.post(LOGGER_URL, json={"event": "request", "path": "/api/data", "payload": payload}, timeout=1)
    except Exception:
        pass
    return jsonify(payload)

@app.route("/api/add_user", methods=["POST"])
def add_user():
    name = request.json.get("name") if request.is_json else None
    if not name:
        return jsonify(error="name is required"), 400
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO users(name) VALUES (%s);", (name,))
            conn.commit()
    except Exception as e:
        return jsonify(error=str(e)), 500
    try:
        requests.post(LOGGER_URL, json={"event": "add_user", "name": name}, timeout=1)
    except Exception:
        pass
    return jsonify(ok=True, name=name)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
