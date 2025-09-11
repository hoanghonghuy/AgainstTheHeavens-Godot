# combat_scene.gd
# Script điều khiển toàn bộ logic cho một trận đấu theo lượt.
extends Control

#===================================================================#
#                             TÍN HIỆU                              #
#===================================================================#

# Tín hiệu này sẽ được phát ra khi trận đấu kết thúc (thắng hoặc thua).
# Scene chính (main_scene) sẽ lắng nghe tín hiệu này.
signal combat_finished

#===================================================================#
#                         TRẠNG THÁI & BIẾN                          #
#===================================================================#

# Enum định nghĩa các trạng thái của trận đấu, giúp quản lý logic rõ ràng.
enum CombatState {
	PLAYER_TURN, # Lượt của người chơi
	ENEMY_TURN,  # Lượt của kẻ địch
	VICTORY,     # Người chơi thắng
	DEFEAT       # Người chơi thua
}

# Biến lưu trữ trạng thái và dữ liệu của trận đấu hiện tại
var current_state: CombatState
var current_enemy_data: EnemyData
var player_current_hp: int
var enemy_current_hp: int

#===================================================================#
#                THAM CHIẾU ĐẾN CÁC NODE GIAO DIỆN                  #
#===================================================================#
# QUAN TRỌNG: Tên của các node trong file scene combat_scene.tscn
# PHẢI KHỚP 100% với các tên được khai báo sau ký hiệu %.

@onready var player_name_label: Label = %PlayerNameLabel
@onready var player_hp_label: Label = %PlayerHPLabel
@onready var player_se_label: Label = %PlayerSELabel
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_hp_label: Label = %EnemyHPLabel
@onready var combat_log: RichTextLabel = %CombatLog
@onready var action_buttons: HBoxContainer = %ActionButtons

#===================================================================#
#                      CÁC HÀM CỐT LÕI CỦA GODOT                    #
#===================================================================#

# Hàm _ready() được gọi một lần khi scene được tải vào cây scene.
func _ready() -> void:
	# Mặc định, màn hình chiến đấu sẽ bị ẩn đi khi game bắt đầu.
	self.hide()

#===================================================================#
#                      LUỒNG CHÍNH CỦA TRẬN ĐẤU                      #
#===================================================================#

# Hàm này được gọi từ bên ngoài (main_scene) để BẮT ĐẦU một trận đấu.
func start_combat(enemy_data: EnemyData) -> void:
	self.show() # Hiện scene chiến đấu lên.
	current_enemy_data = enemy_data
	
	# Khởi tạo chỉ số cho trận đấu từ dữ liệu gốc.
	player_current_hp = PlayerState.healthPoints
	enemy_current_hp = current_enemy_data.maxHp
	
	# Cập nhật giao diện lần đầu tiên.
	update_display()
	
	# Xóa nhật ký cũ và thêm thông báo bắt đầu.
	combat_log.clear()
	add_log_message("Trận đấu bắt đầu! Đối thủ: %s" % current_enemy_data.enemyName)
	
	# Quyết định lượt đi đầu tiên.
	change_state(CombatState.PLAYER_TURN)

# Hàm chuyển đổi trạng thái của trận đấu (trái tim của logic theo lượt).
func change_state(new_state: CombatState) -> void:
	current_state = new_state
	
	match current_state:
		CombatState.PLAYER_TURN:
			add_log_message("Đến lượt của bạn.")
			action_buttons.show() # Hiện các nút hành động để người chơi chọn.
			
		CombatState.ENEMY_TURN:
			add_log_message("Đến lượt của %s." % current_enemy_data.enemyName)
			action_buttons.hide() # Ẩn các nút đi để người chơi không nhấn được.
			# Chờ một chút rồi để kẻ địch hành động, tạo cảm giác có độ trễ.
			await get_tree().create_timer(1.0).timeout
			enemy_action()
			
		CombatState.VICTORY:
			add_log_message("Bạn đã chiến thắng! Nhận được %.1f điểm Tu Vi." % current_enemy_data.cpReward)
			PlayerState.cultivationPoints += current_enemy_data.cpReward
			# Chờ 2 giây rồi phát tín hiệu kết thúc.
			await get_tree().create_timer(2.0).timeout
			combat_finished.emit() # PHÁT TÍN HIỆU!
			
		CombatState.DEFEAT:
			add_log_message("Bạn đã thất bại...")
			# Chờ 2 giây rồi phát tín hiệu kết thúc.
			await get_tree().create_timer(2.0).timeout
			combat_finished.emit() # PHÁT TÍN HIỆU!

#===================================================================#
#                      HÀNH ĐỘNG VÀ LOGIC TÍNH TOÁN                 #
#===================================================================#

# Hàm được gọi khi người chơi nhấn nút "Tấn Công".
func _on_attack_button_pressed() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return # Nếu không phải lượt của người chơi thì không làm gì cả.
	
	var damage = PlayerState.attackPower - current_enemy_data.defense
	damage = max(1, damage) # Sát thương tối thiểu luôn là 1.
	
	enemy_current_hp -= damage
	add_log_message("Bạn tấn công, gây %d sát thương." % damage)
	
	update_display()
	
	if enemy_current_hp <= 0:
		change_state(CombatState.VICTORY)
	else:
		change_state(CombatState.ENEMY_TURN)

# AI đơn giản của kẻ địch.
func enemy_action() -> void:
	var damage = current_enemy_data.attackPower - PlayerState.defense
	damage = max(1, damage)
	
	player_current_hp -= damage
	add_log_message("%s tấn công, gây %d sát thương." % [current_enemy_data.enemyName, damage])
	
	update_display()
	
	if player_current_hp <= 0:
		change_state(CombatState.DEFEAT)
	else:
		change_state(CombatState.PLAYER_TURN)
		
#===================================================================#
#                          HÀM TIỆN ÍCH                             #
#===================================================================#

# Hàm cập nhật toàn bộ hiển thị trên màn hình.
func update_display() -> void:
	player_name_label.text = "Huy" # Sẽ lấy từ PlayerState sau
	player_hp_label.text = "HP: %d / %d" % [player_current_hp, PlayerState.healthPoints]
	player_se_label.text = "Linh Khí: %d / %d" % [PlayerState.spiritEnergy, PlayerState.maxSpiritEnergy]
	
	enemy_name_label.text = current_enemy_data.enemyName
	enemy_hp_label.text = "HP: %d / %d" % [enemy_current_hp, current_enemy_data.maxHp]
	
# Hàm thêm một dòng thông báo vào nhật ký chiến đấu.
func add_log_message(message: String) -> void:
	combat_log.append_text(message + "\n")
