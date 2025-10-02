# map_ui.gd
# Script điều khiển giao diện bản đồ thế giới.
extends Control

# Tín hiệu sẽ được phát ra khi người chơi chọn một địa điểm và nhấn "Dịch Chuyển".
# Tín hiệu này sẽ mang theo ID của địa điểm được chọn.
signal travel_requested(location_id: String)
# Tín hiệu phát ra khi người chơi muốn đóng giao diện bản đồ.
signal closed

#== THAM CHIẾU ĐẾN CÁC NODE TRONG SCENE ==
# Dùng %NodeName là cú pháp của Godot 4 để lấy node nhanh chóng.
@onready var location_list: VBoxContainer = %LocationList
@onready var location_name_label: Label = %LocationNameLabel
@onready var location_description_label: Label = %LocationDescriptionLabel
@onready var travel_button: Button = %TravelButton
@onready var close_button: Button = %CloseButton

# Biến để lưu trữ dữ liệu của địa điểm đang được chọn trên giao diện.
var _selected_location: LocationData = null

# Hàm này được gọi một lần khi node sẵn sàng.
func _ready() -> void:
	# Kết nối tín hiệu của các nút bấm.
	travel_button.pressed.connect(_on_travel_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)

# Hàm này được gọi bởi MainScene để mở và làm mới giao diện bản đồ.
func open_panel():
	# Cập nhật danh sách các nút địa điểm.
	_populate_location_list()
	# Xóa thông tin chi tiết của địa điểm cũ.
	_clear_location_details()
	# Hiển thị giao diện.
	self.show()

# Hàm này tự động tạo danh sách các nút địa điểm dựa trên dữ liệu từ Database.
func _populate_location_list():
	# Xóa các nút cũ trước khi tạo mới để tránh trùng lặp.
	for child in location_list.get_children():
		child.queue_free()
	
	# Lấy tất cả dữ liệu địa điểm từ Database.
	var all_locations = Database.get_all_locations()
	
	for location_id in all_locations:
		var location_data: LocationData = all_locations[location_id]
		var loc_button = Button.new()
		loc_button.text = location_data.location_name
		
		# Nếu là địa điểm hiện tại của người chơi, vô hiệu hóa nút đó.
		if location_id == PlayerState.current_location_id:
			loc_button.disabled = true
			loc_button.text += " (Hiện tại)"
		
		# Kết nối tín hiệu pressed của nút, truyền vào dữ liệu của địa điểm đó.
		loc_button.pressed.connect(_display_location_details.bind(location_data))
		location_list.add_child(loc_button)

# Hàm được gọi khi người chơi nhấn vào một nút địa điểm trong danh sách.
func _display_location_details(location_data: LocationData):
	# Lưu lại dữ liệu địa điểm đã chọn.
	_selected_location = location_data
	# Hiển thị tên và mô tả.
	location_name_label.text = location_data.location_name
	location_description_label.text = location_data.description
	# Kích hoạt nút "Dịch Chuyển".
	travel_button.disabled = false

# Hàm để xóa thông tin chi tiết, thường được gọi khi mở lại bản đồ.
func _clear_location_details():
	_selected_location = null
	location_name_label.text = "Chọn một địa điểm"
	location_description_label.text = ""
	travel_button.disabled = true

# Hàm được gọi khi nhấn nút "Dịch Chuyển".
func _on_travel_button_pressed():
	# Chỉ hoạt động nếu đã có một địa điểm được chọn.
	if _selected_location:
		# Phát tín hiệu mang theo ID của địa điểm.
		travel_requested.emit(_selected_location.location_id)
		# Ẩn giao diện này đi. MainScene sẽ xử lý phần còn lại.
		self.hide()

# Hàm được gọi khi nhấn nút "Đóng".
func _on_close_button_pressed():
	self.hide()
	closed.emit()
