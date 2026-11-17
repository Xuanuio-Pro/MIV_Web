# Phòng chấm MIV 2026 — bản tự chạy trên server

Trang chấm điểm (`phong-cham-miv2026.html`, bản build từ Artifact claude.ai) chạy trên server riêng bằng Docker:
đăng nhập bằng tài khoản giám khảo, điểm và góp ý của mọi người lưu chung và tự đồng bộ khoảng 3 giây một lần.

| File | Vai trò |
|------|---------|
| `phong-cham-miv2026.html` | Trang chấm, đã gộp sẵn dữ liệu 55 sản phẩm + điểm AI. Không sửa tay. |
| `server.js` | Server Node (không có dependency): đăng nhập, API lưu điểm, quản lý tài khoản. |
| `claude-shim.js` | Thay `window.claude` của claude.ai bằng API của `server.js`, nên HTML giữ nguyên. |
| `login.html` | Trang đăng nhập. |
| `template.html`, `build_web.py` | Nguồn để build lại trang khi dữ liệu thay đổi (cần thư mục dữ liệu `E:\MIV2026`, chỉ có trên máy gốc). |

Dữ liệu (tài khoản, điểm) nằm trong Docker volume `miv-data`, **không** nằm trong git và không mất khi build lại.

## Deploy lần đầu trên server (Linux có Docker)

```bash
git clone <URL repo> phong-cham-miv && cd phong-cham-miv
docker compose up -d --build            # chạy ở cổng 8080; đổi cổng: WEB_PORT=80 docker compose up -d --build

# tạo tài khoản: user <tên đăng nhập> <mật khẩu ≥ 8 ký tự> <tên hiển thị>
docker compose exec web node server.js user hinh       '<mật khẩu>' Nguyễn Văn Hinh
docker compose exec web node server.js user giamkhao1  '<mật khẩu>' Giám khảo 1
docker compose exec web node server.js user giamkhao2  '<mật khẩu>' Giám khảo 2
docker compose exec web node server.js user giamkhao3  '<mật khẩu>' Giám khảo 3
```

Mở `http://<IP server>:8080`. Mở cổng trên firewall nếu cần (`sudo ufw allow 8080/tcp`).

## Quản lý tài khoản

```bash
docker compose exec web node server.js user <username> '<mật khẩu mới>' [tên hiển thị]   # thêm mới hoặc đổi mật khẩu/tên
docker compose exec web node server.js deluser <username>                                  # xóa, mất quyền ngay
```

Đổi mật khẩu hay tên hiển thị thì điểm đã chấm vẫn giữ nguyên (gắn với ID nội bộ, không gắn với tên).

## Cập nhật code / dữ liệu sản phẩm

```bash
git pull && docker compose up -d --build
```

Muốn đổi dữ liệu sản phẩm thì chạy `build_web.py` trên máy có thư mục dữ liệu, commit file `phong-cham-miv2026.html` mới, rồi pull trên server.

## Sao lưu

```bash
docker compose cp web:/app/data ./backup-$(date +%F)
```

Trong trang cũng có mục **Xuất dữ liệu** (Excel/CSV/JSON).

## Bảo mật

- Chạy HTTP thường. Nếu ra Internet thì nên đặt sau reverse proxy có HTTPS (Caddy/Nginx) và gửi header `X-Forwarded-Proto: https`; cookie đăng nhập khi đó tự bật `Secure`.
- Repo chứa toàn bộ hồ sơ và điểm AI của các sản phẩm dự thi: để repo ở chế độ **private**.
- Đăng nhập sai 10 lần trong 15 phút thì IP đó bị khóa tạm.
- Log dạng JSON: `docker compose logs -f web`.
