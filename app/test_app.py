from app import app

def test_health():
    client = app.test_client()
    assert client.get("/health").status_code == 200

def test_home():
    client = app.test_client()
    assert client.get("/").get_json()["message"] == "Hello from hello-devops!"
