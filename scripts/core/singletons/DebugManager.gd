# debug_manager.gd
# Singleton này quản lý việc hiển thị các thông điệp debug.
# Dễ dàng bật/tắt tất cả log trong game bằng cách thay đổi biến is_debug_enabled.
extends Node

# Đặt là 'true' khi đang phát triển, 'false' khi build game chính thức.
var is_debug_enabled: bool = true

# Hàm này sẽ thay thế cho lệnh print() ở mọi nơi.
# Nó chỉ in ra console nếu is_debug_enabled là true.
func log(message):
	if is_debug_enabled:
		print("[DEBUG] ", message)
