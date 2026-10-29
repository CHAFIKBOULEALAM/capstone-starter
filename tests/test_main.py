from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root():
    r = client.get("/")
    assert r.status_code == 200
    data = r.json()
    assert data["message"] == "Service DevOps ESISA actif"
    assert data["service"] == "capstone-platform"
    assert data["status"] == "operational"


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_predict():
    assert client.get("/predict?x=1").json()["label"] == "positive"
