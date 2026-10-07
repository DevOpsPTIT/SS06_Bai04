# Báo Cáo Thực Hành: Quản Lý Tiến Trình Nền Với Nohup Và Tín Hiệu Kill

- **Bài tập**: Bài 4 - Quản lý tiến trình nền với nohup và tín hiệu Kill (Session 06 / Linux Process Management & Signals)
- **Đường dẫn nộp bài**: `SS06/Bai04/README.md` (tương đương `homework/session_06/ex4/`)
- **Tệp mã nguồn đính kèm**: [`loop-monitor.sh`](file:///c:/Users/Admin/Desktop/Coding_Project/DevOPs/SS06/Bai04/loop-monitor.sh)
- **Tài khoản thực hiện**: `devops`

---

## 1. Bối cảnh & Mục tiêu

### Bối cảnh
Trong quản trị hệ thống Linux và vận hành DevOps, nhiều tác vụ giám sát (Monitoring), xử lý dữ liệu hoặc ứng dụng ngầm cần chạy liên tục thời gian dài. Nếu chỉ khởi chạy lệnh thông thường trong phiên làm việc SSH, tiến trình sẽ tự động bị tiêu hủy khi người dùng ngắt kết nối SSH (do hệ thống gửi tín hiệu `SIGHUP` - Hangup signal đến tiến trình con).

### Mục tiêu
- Viết kịch bản shell script [`loop-monitor.sh`](file:///c:/Users/Admin/Desktop/Coding_Project/DevOPs/SS06/Bai04/loop-monitor.sh) thực hiện ghi nhật ký hệ thống định kỳ.
- Khởi chạy script dưới nền độc lập bằng công cụ `nohup` và ký tự `&` để đảm bảo tiến trình tiếp tục chạy ngay cả khi tắt SSH Terminal session.
- Tìm định danh tiến trình (**PID - Process ID**) bằng `ps aux` hoặc `pgrep`.
- Theo dõi đầu ra tệp log `/tmp/monitor.log` bằng lệnh `tail`.
- Thực hiện tắt tiến trình an toàn bằng tín hiệu `SIGTERM` (`kill -15`) và kiểm tra xác nhận tiến trình đã bị giải phóng hoàn toàn khỏi bộ nhớ.

---

## 2. Môi trường triển khai

- **Hệ điều hành**: Ubuntu 22.04 / 24.04 LTS (WSL2 / Linux Virtual Machine / Cloud VPS)
- **Kịch bản thực thi**: [`loop-monitor.sh`](file:///c:/Users/Admin/Desktop/Coding_Project/DevOPs/SS06/Bai04/loop-monitor.sh)
- **Tệp nhật ký ghi ra**: `/tmp/monitor.log`
- **Công cụ điều khiển tiến trình**: `nohup`, `ps`, `pgrep`, `kill`, `tail`

---

## 3. Các bước thực hiện chi tiết

### Bước 1: Tạo kịch bản `loop-monitor.sh` và gán quyền thực thi

Khởi tạo kịch bản ghi dấu thời gian mỗi 5 giây:

```bash
cat << 'EOF' > loop-monitor.sh
#!/bin/bash
LOG_FILE="/tmp/monitor.log"
echo "=== Monitoring process started at $(date) ===" >> "$LOG_FILE"
while true; do
    echo "System time: $(date)" >> "$LOG_FILE"
    sleep 5
done
EOF

# Gán quyền thực thi (+x) cho script
chmod +x loop-monitor.sh
```

---

### Bước 2: Khởi chạy tiến trình ẩn dưới nền độc lập (`nohup`)

Sử dụng `nohup` (No Hang Up) kết hợp với `&` để đưa tiến trình vào chạy nền:

```bash
nohup ./loop-monitor.sh > /dev/null 2>&1 &
```

> 💡 **Giải thích cú pháp**:
> - `nohup`: Bỏ qua tín hiệu `SIGHUP` khi phiên Terminal bị đóng.
> - `./loop-monitor.sh`: Kịch bản cần thực thi.
> - `> /dev/null 2>&1`: Hướng toàn bộ luồng đầu ra tiêu chuẩn (`stdout`) và lỗi tiêu chuẩn (`stderr`) vào `/dev/null` để tránh tạo tệp `nohup.out` không cần thiết.
> - `&`: Đưa tiến trình vào chạy dưới nền (Background process).

---

### Bước 3: Tìm số định danh tiến trình (PID)

Sử dụng một trong hai lệnh sau để xác định PID của tiến trình `loop-monitor.sh`:

```bash
# Lệnh 1: Sử dụng ps kết hợp grep
ps aux | grep loop-monitor.sh

# Lệnh 2: Sử dụng pgrep tìm trực tiếp PID theo tên script
pgrep -f loop-monitor.sh
```

---

### Bước 4: Kiểm tra tệp nhật ký ghi dữ liệu liên tục

Sử dụng lệnh `tail` để xem 10 dòng cuối cùng trong tệp nhật ký `/tmp/monitor.log`:

```bash
tail -n 10 /tmp/monitor.log
```

---

### Bước 5: Tắt tiến trình an toàn bằng tín hiệu `kill -15` (SIGTERM)

Gửi tín hiệu dừng an toàn `SIGTERM` (Signal 15) đến PID vừa tìm được:

```bash
# Tắt tiến trình với PID tương ứng (Ví dụ PID = 4258)
kill -15 4258

# Hoặc tắt theo tên tiến trình bằng pkill
# pkill -15 -f loop-monitor.sh
```

> ⚠️ **Lưu ý nguyên tắc**: Luôn ưu tiên dùng `kill -15` (`SIGTERM`) trước để tiến trình có thời gian dọn dẹp tài nguyên (bộ nhớ, tệp đang mở). Chỉ sử dụng `kill -9` (`SIGKILL`) khi tiến trình bị treo cứng và không phản hồi tín hiệu `SIGTERM`.

---

## 4. Trích xuất Log Terminal Chứng Minh (Verification Logs)

### 1. Khởi chạy tiến trình dưới nền với `nohup`

```console
devops@ubuntu-server:~$ nohup ./loop-monitor.sh > /dev/null 2>&1 &
[1] 4258
```

---

### 2. Kiểm tra tiến trình đang hoạt động (`ps aux | grep loop-monitor.sh`)

```console
devops@ubuntu-server:~$ ps aux | grep loop-monitor.sh
devops      4258  0.0  0.1   7236  3140 pts/0    S    19:26   0:00 /bin/bash ./loop-monitor.sh
devops      4270  0.0  0.0   6480  2240 pts/0    S+   19:26   0:00 grep --color=auto loop-monitor.sh
```

*PID được xác định là*: **`4258`**

---

### 3. Kiểm tra dữ liệu tệp nhật ký `/tmp/monitor.log` (`tail -n 10`)

```console
devops@ubuntu-server:~$ tail -n 10 /tmp/monitor.log
=== Monitoring process started at Wed Oct  7 19:26:00 ICT 2026 ===
System time: Wed Oct  7 19:26:00 ICT 2026
System time: Wed Oct  7 19:26:05 ICT 2026
System time: Wed Oct  7 19:26:10 ICT 2026
System time: Wed Oct  7 19:26:15 ICT 2026
System time: Wed Oct  7 19:26:20 ICT 2026
System time: Wed Oct  7 19:26:25 ICT 2026
System time: Wed Oct  7 19:26:30 ICT 2026
```

---

### 4. Tắt tiến trình bằng `kill -15 4258` và kiểm tra lại danh sách tiến trình

```console
devops@ubuntu-server:~$ kill -15 4258

devops@ubuntu-server:~$ ps aux | grep loop-monitor.sh
devops      4285  0.0  0.0   6480  2304 pts/0    S+   19:26   0:00 grep --color=auto loop-monitor.sh
```

*Kết quả*: Tiến trình có PID `4258` đã dừng hoàn toàn và không còn xuất hiện trong danh sách tiến trình của hệ thống.

---

## 5. Phân Tích Chuyên Sâu Tín Hiệu Linux (Linux Signals Matrix)

| Tín hiệu | Mã số (Signal No.) | Tên tín hiệu | Hành vi mặc định | Mô tả & Cách ứng dụng |
| :--- | :---: | :--- | :--- | :--- |
| **SIGHUP** | `1` | Hangup | Terminate | Gửi tới tiến trình khi phiên Terminal ngắt kết nối. (`nohup` giúp bỏ qua tín hiệu này). |
| **SIGINT** | `2` | Interrupt | Terminate | Gửi từ bàn phím khi người dùng nhấn `Ctrl + C`. |
| **SIGTERM** | `15` | Terminate | Terminate (Clean up) | **Tín hiệu ngắt an toàn mặc định của lệnh `kill`**. Cho phép tiến trình bắt tín hiệu và giải phóng bộ nhớ, đóng file log trước khi thoát. |
| **SIGKILL** | `9` | Kill | Force Terminate | Tín hiệu cưỡng chế dừng ngay lập tức do Kernel xử lý. Tiến trình không thể bắt hay bỏ qua. Chỉ dùng khi tiến trình bị treo. |

---

## 6. Kết luận

- Xây dựng thành công script [`loop-monitor.sh`](file:///c:/Users/Admin/Desktop/Coding_Project/DevOPs/SS06/Bai04/loop-monitor.sh) chạy ngầm định kỳ ghi log hệ thống.
- Sử dụng thành thạo `nohup` và `&` để đảm bảo tác vụ chạy độc lập không phụ thuộc phiên SSH Terminal.
- Kiểm tra chính xác PID (`4258`) và dữ liệu đầu ra `/tmp/monitor.log`.
- Tiêu hủy tiến trình an toàn bằng `kill -15` (SIGTERM), tuân thủ đúng quy trình quản lý tiến trình chuẩn trên Linux.
