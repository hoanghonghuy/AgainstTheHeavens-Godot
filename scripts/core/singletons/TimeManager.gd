# TimeManager.gd
# Singleton này quản lý toàn bộ thời gian trong game.
extends Node

# Tín hiệu sẽ phát ra mỗi khi giờ, ngày thay đổi
signal time_changed(current_day, current_hour)
signal day_phase_changed(new_phase) # Gửi đi tên của buổi (BinhMinh, BanNgay...)
signal event_triggered(event_id: String)

# Tỷ lệ thời gian: 1 giây ngoài đời thực = bao nhiêu phút trong game?
const TIME_SCALE = 1.0 # Tạm thời đặt là 1 giây = 1 phút để dễ quan sát

enum DayPhase { BINH_MINH, BAN_NGAY, HOANG_HON, BAN_DEM }

var current_day: int = 1
var current_hour: int = 6 # Bắt đầu vào 6h sáng
var current_minute: float = 0.0
var current_phase: DayPhase = DayPhase.BINH_MINH

# Biến để theo dõi các sự kiện đã được kích hoạt trong ngày
var daily_events_triggered: Array = []

func _process(delta: float):
	# Cộng dồn thời gian
	current_minute += TIME_SCALE * delta

	# Nếu đủ 60 phút, tăng giờ và reset phút
	if current_minute >= 60.0:
		current_minute = 0.0
		current_hour += 1

		# Phát tín hiệu báo giờ đã thay đổi
		time_changed.emit(current_day, current_hour)

		# Nếu đủ 24 giờ, tăng ngày và reset giờ
		if current_hour >= 24:
			current_hour = 0
			current_day += 1
			daily_events_triggered.clear()
			
		# Kiểm tra và thay đổi buổi trong ngày
		_check_day_phase()
		_check_timed_events()
func _check_day_phase():
	var new_phase = _get_phase_for_hour(current_hour)
	if new_phase != current_phase:
		current_phase = new_phase
		day_phase_changed.emit(current_phase)
		print("Thời gian chuyển sang: ", DayPhase.keys()[current_phase])

func _get_phase_for_hour(hour: int) -> DayPhase:
	if hour >= 5 and hour < 7: # 5h-7h: Bình Minh
		return DayPhase.BINH_MINH
	elif hour >= 7 and hour < 18: # 7h-18h: Ban Ngày
		return DayPhase.BAN_NGAY
	elif hour >= 18 and hour < 20: # 18h-20h: Hoàng Hôn
		return DayPhase.HOANG_HON
	else: # Các giờ còn lại: Ban Đêm
		return DayPhase.BAN_DEM

# Hàm để các script khác có thể lấy chuỗi thời gian
func get_time_string() -> String:
	return "Ngày %d, %02d:%02d" % [current_day, current_hour, int(current_minute)]

# HÀM MỚI: Kiểm tra các sự kiện có thể xảy ra vào giờ này
func _check_timed_events():
	# Sự kiện: Yêu thú đêm xuất hiện
	var event_id = "event_night_beast_spawn"
	# Điều kiện: Là ban đêm VÀ sự kiện này chưa được kích hoạt hôm nay
	if current_phase == DayPhase.BAN_DEM and not event_id in daily_events_triggered:
		# Tỷ lệ xảy ra: 50%
		if randf() < 0.5:
			event_triggered.emit(event_id)
			daily_events_triggered.append(event_id) # Đánh dấu đã kích hoạt
			print("SỰ KIỆN KÍCH HOẠT: ", event_id)
