# inventory_scene.gd
extends Control

signal closed

# Nạp trước "khuôn mẫu" ô vật phẩm để có thể tạo ra hàng loạt
const InventorySlot = preload("res://scenes/ui/inventory_slot.tscn")

# Tham chiếu đến các node giao diện
@onready var item_grid_container: GridContainer = %ItemGridContainer
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_description_label: Label = %ItemDescriptionLabel
@onready var item_type_label: Label = %ItemTypeLabel

# Hàm này được gọi khi node sẵn sàng, dùng để cập nhật giao diện lần đầu
func _ready() -> void:
	# Kết nối tín hiệu của PlayerState (sẽ tạo sau) để tự động cập nhật túi đồ
	# PlayerState.inventory_changed.connect(update_display)
	pass

# Hàm này sẽ được gọi mỗi khi túi đồ được mở hoặc có thay đổi
func update_display() -> void:
	# 1. Xóa sạch các ô vật phẩm cũ
	for child in item_grid_container.get_children():
		child.queue_free()
	
	# 2. Xóa thông tin chi tiết
	display_item_details(null)
	
	# --- BẮT ĐẦU VÙNG DEBUG ---
	print("==========================================")
	print("Bắt đầu cập nhật túi đồ...")
	print("Dữ liệu túi đồ trong PlayerState: ", PlayerState.inventory)
	print("Dữ liệu vật phẩm trong Database: ", Database.items.keys())
	print("------------------------------------------")
	# --- KẾT THÚC VÙNG DEBUG ---
	
	# 3. Tạo lại các ô vật phẩm từ dữ liệu của PlayerState
	for item_id in PlayerState.inventory:
		var quantity = PlayerState.inventory[item_id]
		print("Đang xử lý vật phẩm với ID: '", item_id, "'")
		var item_data = Database.items.get(item_id)
		
		if item_data:
			print(">> Đã tìm thấy dữ liệu cho '", item_id, "' trong Database. Đang tạo ô...")
			# Tạo một ô vật phẩm mới từ khuôn mẫu
			var slot = InventorySlot.instantiate()
			# Thêm ô vật phẩm vào lưới
			item_grid_container.add_child(slot)
			# Gửi dữ liệu vào cho ô đó hiển thị
			slot.display_item(item_data, quantity)
			# Kết nối tín hiệu chuột để hiển thị thông tin chi tiết
			slot.gui_input.connect(_on_slot_gui_input.bind(item_data))
			
		else:
			print(">> LỖI: KHÔNG tìm thấy dữ liệu cho '", item_id, "' trong Database!")
	print("==========================================")
# Hàm được gọi khi có tương tác chuột trên một ô vật phẩm
func _on_slot_gui_input(event: InputEvent, item_data: ItemData):
	# Nếu là nhấn chuột trái
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		display_item_details(item_data)

# Hàm hiển thị thông tin chi tiết của một vật phẩm
func display_item_details(item_data: ItemData) -> void:
	if item_data:
		item_name_label.text = item_data.itemName
		item_description_label.text = item_data.description
		# Chuyển đổi Enum thành dạng chữ để hiển thị
		item_type_label.text = "Loại: %s" % ItemData.ItemType.keys()[item_data.itemType]
	else:
		item_name_label.text = "..."
		item_description_label.text = "Chọn một vật phẩm để xem chi tiết."
		item_type_label.text = "Loại: ..."
		
		
# Hàm được gọi khi nút "Đóng" được nhấn
func _on_close_button_pressed() -> void:
	self.hide()
	closed.emit() # Phát tín hiệu báo đã đóng
