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
@onready var cultivation_method_ui: Control = %CultivationMethodUI
@onready var time_label: Label = %TimeLabel
@onready var day_night_overlay: ColorRect = %DayNightOverlay
@onready var night_wolf: Area2D = %NightWolf
@onready var map_ui: Control = %MapUI

# Tham chiếu đến các nút bấm và label trong MainUI
@onready var cultivation_label: Label = %CultivationLabel
@onready var spirit_stone_label: Label = %SpiritStoneLabel
@onready var realm_label: Label = %RealmLabel
@onready var spirit_energy_label: Label = %SpiritEnergyLabel
@onready var breakthrough_button: Button = %BreakthroughButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var map_button: Button = %MapButton

# Từ điển chứa các màu sắc cho từng buổi trong ngày
const DAY_PHASE_COLORS = {
	TimeManager.DayPhase.BINH_MINH: Color(1, 0.8, 0.6, 0.1),  # Vàng cam nhạt
	TimeManager.DayPhase.BAN_NGAY: Color(1, 1, 1, 0.0),      # Hoàn toàn trong suốt
	TimeManager.DayPhase.HOANG_HON: Color(0.8, 0.4, 0.2, 0.2), # Đỏ cam đậm
	TimeManager.DayPhase.BAN_DEM: Color(0.1, 0.1, 0.3, 0.4)   # Xanh đen đậm
}

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
	cultivation_method_ui.closed.connect(_on_cultivation_method_closed)
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.day_phase_changed.connect(_on_day_phase_changed)
	
	## Tự động tìm và kết nối tín hiệu cho tất cả NPC trong World
	#for npc in world.get_children():
		#if npc.has_signal("interacted"):
			#npc.interacted.connect(_on_npc_interacted)
			
	# Tự động tìm và kết nối tín hiệu cho tất cả các đối tượng trong World
	for child in world.get_children():
		if child.has_signal("interacted"): # Dành cho NPC
			child.interacted.connect(_on_npc_interacted)
		elif child.has_signal("combat_initiated"): # DÀNH CHO KẺ ĐỊCH
			child.combat_initiated.connect(_on_enemy_combat_initiated)
			
	# Vô hiệu hóa nút Tải Game nếu file save không tồn tại
	load_button.disabled = not SaveManager.has_save_file()
	
	# Cập nhật hiển thị chỉ số lần đầu tiên
	update_stats_display()
	# Cập nhật hiển thị thời gian ngay lập tức khi game bắt đầu
	_on_time_changed(TimeManager.current_day, TimeManager.current_hour)

#====================================================#
#               QUẢN LÝ CÁC MÀN HÌNH & TƯƠNG TÁC      #
#====================================================#

# Được gọi khi một NPC phát tín hiệu "interacted"
func _on_npc_interacted(npc_data: NPCData):
	var dialogue_script_to_play = []
	
	# Logic quyết định xem nên nói câu gì
	var quest_id = "quest_first_steps" # Tạm thời hardcode, sau này sẽ lấy từ NPCData
	
	if PlayerState.is_quest_completable(quest_id):
		dialogue_script_to_play = npc_data.dialogue_scripts.get("quest_complete")
	elif PlayerState.quest_progress.has(quest_id):
		dialogue_script_to_play = npc_data.dialogue_scripts.get("quest_inprogress")
	else:
		dialogue_script_to_play = npc_data.dialogue_scripts.get("default")

	if not dialogue_script_to_play.is_empty():
		main_ui.hide()
		dialogue_blocker.show()
		dialogue_ui.start_dialogue(dialogue_script_to_play)
	else:
		print("Lỗi: Không tìm thấy kịch bản hội thoại phù hợp cho NPC.")
			
			
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
		
		# LOGIC MỚI: Lấy hiệu quả từ công pháp đang kích hoạt
		var active_method_id = PlayerState.activeCultivationMethodId
		var method_data: CultivationMethodData = Database.cultivation_methods.get(active_method_id)
		
		var cp_gain = 0.0 # Mặc định không nhận được gì
		if method_data and method_data.passiveEffects.has("cultivationPoints_per_action"):
			cp_gain = method_data.passiveEffects["cultivationPoints_per_action"]
			
		PlayerState.cultivationPoints += cp_gain
		
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
	elif action == "complete_quest":
		var quest_id = "quest_first_steps" # Tạm thời hardcode
		PlayerState.complete_quest(quest_id)
		_on_dialogue_close_requested()	
		
	elif action == "close_dialogue":
		_on_dialogue_close_requested()

func _on_cultivation_method_button_pressed() -> void:
	cultivation_method_ui.open_panel()
	main_ui.hide()
	world.hide()

func _on_cultivation_method_closed() -> void:
	main_ui.show()
	world.show()

#====================================================#
#               QUẢN LÝ THỜI GIAN                    #
#====================================================#

# Được gọi mỗi khi giờ trong game thay đổi
func _on_time_changed(current_day, current_hour):
	time_label.text = TimeManager.get_time_string()

# Được gọi mỗi khi buổi trong ngày thay đổi (Bình Minh, Ban Ngày...)
func _on_day_phase_changed(new_phase):
	# Dùng Tween để chuyển màu mượt mà
	var tween = create_tween()
	tween.tween_property(day_night_overlay, "color", DAY_PHASE_COLORS[new_phase], 2.0) # Chuyển màu trong 2 giây
	if new_phase != TimeManager.DayPhase.BAN_DEM and night_wolf.visible:
		night_wolf.hide()
		#add_log_message_to_main_screen("Trời sáng, Dạ Lang đã rút lui vào bóng tối.")

#====================================================#
#               QUẢN LÝ SỰ KIỆN                      #
#====================================================#

func _on_event_triggered(event_id: String):
	if event_id == "event_night_beast_spawn":
		# Nếu sói đêm chưa xuất hiện, cho nó hiện ra
		if not night_wolf.visible:
			night_wolf.show()
			#add_log_message_to_main_screen("Trời tối, một con Dạ Lang đã xuất hiện gần đây!")

func _on_enemy_combat_initiated(enemy_data: EnemyData):
	main_ui.hide()
	world.hide()
	combat_scene.start_combat(enemy_data)


func _on_map_button_pressed() -> void:
	main_ui.hide()
	map_ui.show()
