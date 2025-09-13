# cave_mansion_ui.gd
extends Control

# Tín hiệu báo cho MainScene biết người chơi muốn đóng giao diện này
signal closed

const EFFECT_NAMES = {
	"spirit_energy_regen": "Hồi Phục Linh Khí (/giây)",
	"spirit_grass_yield": "Sản Lượng Linh Thảo (/giờ)"
	# Sau này sẽ thêm các hiệu ứng khác vào đây
}

#== THAM CHIẾU ĐẾN CÁC NODE GIAO DIỆN ==
@onready var building_list_container: VBoxContainer = %BuildingListContainer
@onready var building_name_label: Label = %BuildingNameLabel
@onready var building_level_label: Label = %BuildingLevelLabel
@onready var building_description_label: Label = %BuildingDescriptionLabel
@onready var effects_container: VBoxContainer = %EffectsContainer
@onready var upgrade_cost_container: VBoxContainer = %UpgradeCostContainer
@onready var upgrade_button: Button = %UpgradeButton
@onready var close_button: Button = %CloseButton

# Biến để lưu trữ ID của công trình đang được chọn
var selected_building_id: String = ""

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	self.hide()

# Hàm này sẽ được gọi từ MainScene để mở giao diện
func open_panel():
	self.show()
	_update_all_displays()

func _on_close_button_pressed():
	self.hide()
	closed.emit()

#====================================================#
#               LOGIC HIỂN THỊ CHÍNH                  #
#====================================================#

func _update_all_displays():
	_populate_building_list()
	
	# Mặc định chọn công trình đầu tiên nếu chưa chọn
	if selected_building_id.is_empty() and not PlayerState.building_levels.is_empty():
		selected_building_id = PlayerState.building_levels.keys()[0]
		
	_display_building_details()

func _populate_building_list():
	for child in building_list_container.get_children():
		child.queue_free()
	
	for building_id in PlayerState.building_levels:
		var current_level = PlayerState.building_levels[building_id]
		# Lấy thông tin của cấp hiện tại từ Database
		var building_level_data = Database.buildings[building_id][current_level - 1]
		
		var button = Button.new()
		button.text = building_level_data.name
		button.pressed.connect(_on_building_selected.bind(building_id))
		building_list_container.add_child(button)

func _on_building_selected(building_id: String):
	selected_building_id = building_id
	_display_building_details()

func _display_building_details():
	if selected_building_id.is_empty() or not Database.buildings.has(selected_building_id):
		building_name_label.text = "Chọn một công trình"
		# ... (dọn dẹp các mục khác)
		return

	var current_level = PlayerState.building_levels[selected_building_id]
	var all_levels_data = Database.buildings[selected_building_id]
	var current_level_data = all_levels_data[current_level - 1]

	# Hiển thị thông tin cấp hiện tại
	building_name_label.text = current_level_data.name
	building_level_label.text = "Cấp: %d" % current_level
	building_description_label.text = current_level_data.description
	
	# Hiển thị hiệu quả
	for child in effects_container.get_children(): child.queue_free()
	for effect_key in current_level_data.effects:
	# Lấy tên đã được dịch từ "từ điển", nếu không có thì dùng lại tên mã
		var effect_name = EFFECT_NAMES.get(effect_key, effect_key)
		var effect_value = current_level_data.effects[effect_key]

		var label = Label.new()
		label.text = "- %s: +%s" % [effect_name, str(effect_value)]
		effects_container.add_child(label)
		
	# Hiển thị yêu cầu nâng cấp
	for child in upgrade_cost_container.get_children(): child.queue_free()
	if current_level < all_levels_data.size():
		var next_level_data = all_levels_data[current_level]
		var can_upgrade = true
		for cost_key in next_level_data.upgrade_cost:
			var required_qty = next_level_data.upgrade_cost[cost_key]
			# SỬA LẠI TÊN BIẾN CHO ĐÚNG
			var player_qty = PlayerState.spiritStones
			
			var label = Label.new()
			label.text = "- Linh Thạch: %d / %d" % [player_qty, required_qty]
			if player_qty < required_qty:
				label.add_theme_color_override("font_color", Color.RED)
				can_upgrade = false
			upgrade_cost_container.add_child(label)
		upgrade_button.disabled = not can_upgrade
		upgrade_button.text = "Nâng Cấp"
	else:
		upgrade_button.disabled = true
		upgrade_button.text = "Đã Tối Đa"
		var label = Label.new()
		label.text = "Đã đạt cấp tối đa."
		upgrade_cost_container.add_child(label)

#====================================================#
#                 LOGIC NÂNG CẤP                    #
#====================================================#
func _on_upgrade_button_pressed():
	if selected_building_id.is_empty() or upgrade_button.disabled:
		return

	var current_level = PlayerState.building_levels[selected_building_id]
	var next_level_data = Database.buildings[selected_building_id][current_level]
	
	# Trừ tài nguyên
	var cost = next_level_data.upgrade_cost["spirit_stones"]
	PlayerState.spirit_stones -= cost
	
	# Tăng cấp công trình
	PlayerState.building_levels[selected_building_id] += 1
	
	print("Nâng cấp %s thành công!" % next_level_data.name)
	
	# Cập nhật lại toàn bộ giao diện
	_update_all_displays()
