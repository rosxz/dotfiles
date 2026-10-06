import os
import signal
import socket
import sys


def serve(sock_path):
    from manga_ocr import MangaOcr

    mocr = MangaOcr()
    if os.path.exists(sock_path):
        os.remove(sock_path)

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(sock_path)
    os.chmod(sock_path, 0o600)
    server.listen(16)

    def shutdown(*_):
        server.close()
        try:
            os.remove(sock_path)
        except OSError:
            pass
        sys.exit(0)

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    while True:
        try:
            conn, _ = server.accept()
        except OSError:
            break
        with conn:
            buf = b""
            while b"\n" not in buf:
                chunk = conn.recv(4096)
                if not chunk:
                    break
                buf += chunk
            path = buf.split(b"\n", 1)[0].decode("utf-8", "replace").strip()
            if not path:
                continue
            try:
                text = mocr(path)
            except Exception:
                text = ""
            conn.sendall((text + "\n").encode("utf-8"))


def client(sock_path, image):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(sock_path)
    sock.sendall((image + "\n").encode("utf-8"))
    sock.shutdown(socket.SHUT_WR)
    chunks = []
    while True:
        chunk = sock.recv(65536)
        if not chunk:
            break
        chunks.append(chunk)
    sock.close()
    sys.stdout.write(b"".join(chunks).decode("utf-8", "replace"))


if __name__ == "__main__":
    if sys.argv[1] == "serve":
        serve(sys.argv[2])
    elif sys.argv[1] == "client":
        client(sys.argv[2], sys.argv[3])
