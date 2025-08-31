import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import app as backend


def test_health():
    client = backend.app.test_client()
    resp = client.get("/api/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"