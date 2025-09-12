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
var is_player_defending: bool = false # Biến ghi nhớ trạng thái phòng ngự

@onready var skill_panel: PanelContainer = %SkillPanel
@onready var skill_list_container: VBoxContainer = %SkillListContainer
@onready var item_panel: PanelContainer = %ItemPanel
@onready var item_list_container: VBoxContainer = %ItemListContainer

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
	is_player_defending = false
	# Cập nhật giao diện lần đầu tiên.
	update_display()
	
	# Xóa nhật ký cũ và thêm thông báo bắt đầu.
	combat_log.clear()
	add_log_message("Trận đấu bắt đầu! Đối thủ: %s" % current_enemy_data.enemyName)
	
	populate_skill_list()
	populate_item_list()
	
	# Quyết định lượt đi đầu tiên.
	change_state(CombatState.PLAYER_TURN)

# Hàm chuyển đổi trạng thái của trận đấu (trái tim của logic theo lượt).
func change_state(new_state: CombatState) -> void:
	current_state = new_state
	
	match current_state:
		CombatState.PLAYER_TURN:
			skill_panel.hide()
			item_panel.hide()
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
	var damage = current_enemy_data.attackPower
	var player_defense = PlayerState.defense

	# Nếu người chơi đang phòng ngự, tăng gấp đôi phòng thủ cho lượt này
	if is_player_defending:
		player_defense *= 2
		add_log_message("Bạn đang phòng ngự!")
	
	damage -= player_defense
	damage = max(1, damage)
	
	player_current_hp -= damage
	add_log_message("%s tấn công, gây %d sát thương." % [current_enemy_data.enemyName, damage])
	
	# QUAN TRỌNG: Sau khi kẻ địch tấn công xong, hủy trạng thái phòng ngự
	is_player_defending = false
	
	update_display()
	
	if player_current_hp <= 0:
		change_state(CombatState.DEFEAT)
	else:
		change_state(CombatState.PLAYER_TURN)


# Được gọi khi người chơi nhấn nút "Phòng Ngự"
func _on_defend_button_pressed() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return
	
	is_player_defending = true # Đặt trạng thái phòng ngự
	add_log_message("Bạn giơ tay phòng ngự, chuẩn bị đỡ đòn.")
	
	# Sau khi phòng ngự, chuyển ngay sang lượt của kẻ địch
	change_state(CombatState.ENEMY_TURN)
	
# Hàm được gọi khi nhấn nút "Kỹ Năng" trên thanh hành động chính
func _on_skill_button_pressed() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return
	# Hiện hoặc ẩn bảng chọn kỹ năng
	skill_panel.visible = not skill_panel.visible

# Hàm tạo các nút kỹ năng một cách tự động
func populate_skill_list() -> void:
	# Xóa các nút kỹ năng cũ (nếu có)
	for child in skill_list_container.get_children():
		child.queue_free()
		
	# Lặp qua danh sách các kỹ năng người chơi đã học
	for skill_id in PlayerState.learnedSkills:
		# Lấy thông tin chi tiết của kỹ năng từ Database
		var skill_data: SkillData = Database.skills.get(skill_id)
		
		if skill_data:
			var skill_button = Button.new()
			# Hiển thị tên và năng lượng tiêu hao trên nút
			skill_button.text = "%s (%d Linh Khí)" % [skill_data.skillName, skill_data.spiritEnergyCost]
			# Kết nối tín hiệu pressed của nút này với hàm use_skill, truyền vào skill_data
			skill_button.pressed.connect(use_skill.bind(skill_data))
			skill_list_container.add_child(skill_button)

# Hàm được gọi khi một nút kỹ năng cụ thể được nhấn
func use_skill(skill_data: SkillData) -> void:
	if current_state != CombatState.PLAYER_TURN:
		return
	
	# 1. Kiểm tra điều kiện sử dụng (đủ Linh Khí)
	if PlayerState.spiritEnergy < skill_data.spiritEnergyCost:
		add_log_message("Linh khí không đủ để thi triển %s!" % skill_data.skillName)
		return # Không làm gì cả
	
	# 2. Trừ Linh Khí
	PlayerState.spiritEnergy -= skill_data.spiritEnergyCost
	
	# 3. Tính sát thương
	var base_damage = PlayerState.attackPower * skill_data.damageMultiplier
	var final_damage = base_damage - current_enemy_data.defense
	final_damage = max(1, final_damage) # Sát thương tối thiểu là 1
	
	# 4. Gây sát thương và thông báo
	enemy_current_hp -= final_damage
	add_log_message("Bạn thi triển %s, gây %.0f sát thương!" % [skill_data.skillName, final_damage])
	
	# 5. Cập nhật giao diện và chuyển lượt
	update_display()
	if enemy_current_hp <= 0:
		change_state(CombatState.VICTORY)
	else:
		change_state(CombatState.ENEMY_TURN)

#===================================================================#
#                      HÀNH ĐỘNG VẬT PHẨM (MỚI)                     #
#===================================================================#
func _on_item_button_pressed() -> void:
	if current_state != CombatState.PLAYER_TURN: return
	item_panel.visible = not item_panel.visible # Hiện/ẩn bảng vật phẩm
	skill_panel.hide() # Ẩn bảng kỹ năng đi để tránh chồng chéo

func populate_item_list() -> void:
	for child in item_list_container.get_children():
		child.queue_free()
	
	for item_id in PlayerState.inventory:
		var item_data: ItemData = Database.items.get(item_id)
		var quantity: int = PlayerState.inventory[item_id]
		
		if item_data and item_data.itemType == ItemData.ItemType.CONSUMABLE and item_data.isUsable:
			var item_button = Button.new()
			item_button.text = "%s (x%d)" % [item_data.itemName, quantity]
			item_button.pressed.connect(use_item.bind(item_id))
			item_list_container.add_child(item_button)

func use_item(item_id: String) -> void:
	if current_state != CombatState.PLAYER_TURN: return

	var item_data: ItemData = Database.items.get(item_id)
	
	# Xử lý hiệu ứng
	if item_data.effects.has("healthPoints"):
		var heal_amount = item_data.effects["healthPoints"]
		player_current_hp += heal_amount
		# Đảm bảo máu không vượt quá tối đa
		player_current_hp = min(player_current_hp, PlayerState.healthPoints)
		add_log_message("Bạn dùng %s, hồi phục %.0f Sinh Mệnh." % [item_data.itemName, heal_amount])
	
	# Trừ vật phẩm khỏi túi đồ
	PlayerState.inventory[item_id] -= 1
	if PlayerState.inventory[item_id] <= 0:
		PlayerState.inventory.erase(item_id)
	
	# Cập nhật lại danh sách vật phẩm và chuyển lượt
	populate_item_list()
	update_display()
	change_state(CombatState.ENEMY_TURN)


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
