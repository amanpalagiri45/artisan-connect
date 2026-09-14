import socket
import uvicorn
from app.config import settings

def get_lan_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

if __name__ == "__main__":
    lan_ip = get_lan_ip()
    print("=" * 60)
    print(f"🚀 {settings.PROJECT_NAME} running on 0.0.0.0:{settings.PORT}")
    print(f"📱 Mobile Device (Wi-Fi LAN) URL: http://{lan_ip}:{settings.PORT}/api/v1")
    print(f"📖 Interactive Swagger API Docs:   http://{lan_ip}:{settings.PORT}/docs")
    print("=" * 60)
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )
