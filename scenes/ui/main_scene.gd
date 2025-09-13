# main_scene.gd
# Script này là "bộ não" tổng của game, điều khiển giao diện chính
# và quản lý việc chuyển đổi giữa các màn hình khác nhau.
extends Control

#====================================================#
#               THAM CHIẾU ĐẾN CÁC NODE               #
#====================================================#
# QUAN TRỌNG: Đảm bảo tên của các node trong scene main_scene.tscn
# đã được đánh dấu "Access as Scene Unique Name" và khớp với các tên sau.

# Tham chiếu đến các container/scene chính
@onready var main_ui: Control = %MainUI
@onready var combat_scene: Control = %CombatScene
@onready var inventory_scene: Control = %InventoryScene
@onready var dialogue_ui: Control = %DialogueUI
@onready var world: Node2D = %World
@onready var dialogue_blocker: ColorRect = %DialogueBlocker
@onready var alchemy_ui: Control = %AlchemyUI
@onready var quest_log_ui: Control = %QuestLogUI
@onready var cave_mansion_ui: Control = %CaveMansionUI

# Tham chiếu đến các nút bấm và label trong MainUI
@onready var cultivation_label: Label = %CultivationLabel
@onready var spirit_stone_label: Label = %SpiritStoneLabel
@onready var realm_label: Label = %RealmLabel
@onready var spirit_energy_label: Label = %SpiritEnergyLabel
@onready var breakthrough_button: Button = %BreakthroughButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton

#====================================================#
#                  HÀM KHỞI TẠO CỦA GODOT              #
#====================================================#

func _ready() -> void:
	# Kết nối các tín hiệu từ các scene con để lắng nghe sự kiện
	combat_scene.combat_finished.connect(_on_combat_finished)
	inventory_scene.closed.connect(_on_inventory_closed)
	dialogue_ui.close_requested.connect(_on_dialogue_close_requested)
	dialogue_blocker.gui_input.connect(_on_dialogue_blocker_input)
	alchemy_ui.closed.connect(_on_alchemy_closed)
	dialogue_ui.option_selected.connect(_on_dialogue_option_selected)
	quest_log_ui.closed.connect(_on_quest_log_closed)
	cave_mansion_ui.closed.connect(_on_cave_mansion_closed)
	PlayerState.stats_changed.connect(update_stats_display)
	
	# Tự động tìm và kết nối tín hiệu cho tất cả NPC trong World
	for npc in world.get_children():
		if npc.has_signal("interacted"):
			npc.interacted.connect(_on_npc_interacted)
	
	# Vô hiệu hóa nút Tải Game nếu file save không tồn tại
	load_button.disabled = not SaveManager.has_save_file()
	
	# Cập nhật hiển thị chỉ số lần đầu tiên
	update_stats_display()

#====================================================#
#               QUẢN LÝ CÁC MÀN HÌNH & TƯƠNG TÁC      #
#====================================================#

# Được gọi khi một NPC phát tín hiệu "interacted"
func _on_npc_interacted(npc_data: NPCData):
	# Dòng print để kiểm tra dữ liệu nhận được
	print("MainScene đã nhận tín hiệu từ NPC: ", npc_data.npcName)
	# SỬA LẠI: In ra số lượng trang hội thoại thay vì nội dung
	print("--> Số lượng trang hội thoại nhận được: ", npc_data.dialogue_pages.size())

	# Kiểm tra xem dữ liệu có hợp lệ và có trang hội thoại nào không
	if npc_data and not npc_data.dialogue_pages.is_empty():
		main_ui.hide() # Ẩn giao diện chính để tránh click nhầm
		dialogue_blocker.show()
		dialogue_ui.start_dialogue(npc_data.dialogue_pages)
	else:
		if not npc_data:
			print("LỖI: Dữ liệu NPC nhận được là rỗng!")
		else:
			print("LỖI: NPC '%s' không có trang hội thoại nào." % npc_data.npcName)
			
			
# Được gọi khi màn chắn VÔ HÌNH được click
func _on_dialogue_blocker_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Ra lệnh cho hộp thoại xử lý cú click này (để skip text hoặc đóng)
		dialogue_ui.handle_click()

# Được gọi khi hộp thoại phát tín hiệu YÊU CẦU ĐÓNG
func _on_dialogue_close_requested():
	dialogue_ui.end_dialogue()
	dialogue_blocker.hide()
	main_ui.show()

# Được gọi khi nhấn nút "Túi Đồ"
func _on_inventory_button_pressed() -> void:
	inventory_scene.update_display() # Luôn làm mới túi đồ trước khi hiện
	inventory_scene.show()
	main_ui.hide()
	world.hide()

# Được gọi khi túi đồ phát tín hiệu đã đóng
func _on_inventory_closed() -> void:
	main_ui.show()
	world.show()
	
# Được gọi khi trận đấu kết thúc
func _on_combat_finished() -> void:
	combat_scene.hide()
	main_ui.show()
	world.show()
	update_stats_display()

# Được gọi khi nhấn nút Khiêu Chiến
func _on_challenge_button_pressed() -> void:
	var enemy_to_fight = load("res://data/enemies/rival_disciple.tres")
	if enemy_to_fight:
		main_ui.hide()
		world.hide()
		combat_scene.start_combat(enemy_to_fight)
	else:
		print("Lỗi: Không tìm thấy dữ liệu kẻ địch!")

# Được gọi khi nhấn nút "Luyện Đan"
func _on_alchemy_button_pressed() -> void:
	alchemy_ui.open_panel() # Gọi hàm công khai để mở và cập nhật panel
	main_ui.hide()
	world.hide()

# Được gọi khi giao diện Luyện Đan phát tín hiệu đã đóng
func _on_alchemy_closed() -> void:
	main_ui.show()
	world.show()
	
# HÀM MỚI: Được gọi khi nhấn nút "Nhiệm Vụ"
func _on_quest_log_button_pressed() -> void:
	quest_log_ui.open_panel()
	main_ui.hide()
	world.hide()

# HÀM MỚI: Được gọi khi giao diện Nhiệm Vụ phát tín hiệu đã đóng
func _on_quest_log_closed() -> void:
	main_ui.show()
	world.show()
	
func _on_cave_mansion_button_pressed() -> void:
	cave_mansion_ui.open_panel()
	main_ui.hide()
	world.hide()

func _on_cave_mansion_closed() -> void:
	main_ui.show()
	world.show()
#====================================================#
#               QUẢN LÝ LƯU & TẢI GAME                 #
#====================================================#

func _on_save_button_pressed() -> void:
	SaveManager.save_game()
	load_button.disabled = false

func _on_load_button_pressed() -> void:
	SaveManager.load_game()
	update_stats_display()

#====================================================#
#               CÁC HÀNH ĐỘNG CỦA NGƯỜI CHƠI          #
#====================================================#

func update_stats_display() -> void:
	cultivation_label.text = "Tu Vi: %.1f" % PlayerState.cultivationPoints
	spirit_stone_label.text = "Linh Thạch: %d" % PlayerState.spiritStones
	realm_label.text = "Cảnh Giới: %s" % PlayerState.cultivationRealm
	spirit_energy_label.text = "Linh Khí: %d / %d" % [int(PlayerState.spiritEnergy), PlayerState.maxSpiritEnergy]
	
	var next_realm_index = PlayerState.currentRealmIndex + 1
	if next_realm_index < Database.realms.size():
		var next_realm_info = Database.realms[next_realm_index]
		var required_cp = next_realm_info.requiredCp
		breakthrough_button.text = "Đột Phá (%.0f Tu Vi)" % required_cp
		breakthrough_button.disabled = PlayerState.cultivationPoints < required_cp
	else:
		breakthrough_button.text = "Đã Tới Đỉnh Cao"
		breakthrough_button.disabled = true

func _on_cultivate_button_pressed() -> void:
	if PlayerState.spiritEnergy >= 5:
		PlayerState.spiritEnergy -= 5
		PlayerState.cultivationPoints += 1.5
		update_stats_display()

func _on_rest_button_pressed() -> void:
	PlayerState.spiritEnergy += 15
	PlayerState.spiritEnergy = min(PlayerState.spiritEnergy, PlayerState.maxSpiritEnergy)
	update_stats_display()

func _on_breakthrough_button_pressed() -> void:
	if PlayerState.attempt_breakthrough():
		print("Đột phá thành công lên cảnh giới mới!")
	update_stats_display()


func _on_dialogue_option_selected(option_data: Dictionary):
	var action = option_data.get("action", "")
	
	if action == "accept_quest":
		var quest_id = option_data.get("quest_id", "")
		PlayerState.accept_quest(quest_id)
		# Sau khi nhận quest, đóng hội thoại
		_on_dialogue_close_requested()
		
	elif action == "close_dialogue":
		_on_dialogue_close_requested()
