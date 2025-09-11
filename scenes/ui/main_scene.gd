# main_scene.gd
# Script điều khiển logic cho giao diện chính của game.
extends Control

# Tham chiếu đến các container chính và scene chiến đấu
@onready var main_ui: Control = %MainUI
@onready var combat_scene: Control = %CombatScene

#== Lấy tham chiếu đến các Node Label trong Scene ==
# Dùng @onready để đảm bảo các node này đã tồn tại trước khi script truy cập chúng.
# Ký tự `$` là cách viết tắt của hàm get_node().
@onready var cultivation_label: Label = %CultivationLabel
@onready var spirit_stone_label: Label = %SpiritStoneLabel
@onready var realm_label: Label = %RealmLabel
@onready var spirit_energy_label: Label = %SpiritEnergyLabel
@onready var breakthrough_button: Button = %BreakthroughButton

func _ready() -> void:
	# Kết nối tín hiệu "combat_finished" từ CombatScene đến một hàm trong script này
	combat_scene.combat_finished.connect(_on_combat_finished)
	update_stats_display()
	
# Hàm được gọi khi trận đấu kết thúc
func _on_combat_finished() -> void:
	combat_scene.hide() # Ẩn màn hình chiến đấu
	main_ui.show()      # Hiện lại giao diện chính
	update_stats_display() # Cập nhật lại chỉ số (với phần thưởng nếu có)

#== Hàm cập nhật hiển thị chỉ số ==
# Hàm này sẽ lấy dữ liệu từ Singleton PlayerState và gán vào các Label.
func update_stats_display() -> void:
	# Dùng String Formatting để tạo chuỗi hiển thị.
	# %s là placeholder cho chuỗi (String)
	# %d là placeholder cho số nguyên (integer)
	# %.1f là placeholder cho số thực (float) với 1 chữ số sau dấu phẩy.
	cultivation_label.text = "Tu Vi: %.1f" % PlayerState.cultivationPoints
	spirit_stone_label.text = "Linh Thạch: %d" % PlayerState.spiritStones
	realm_label.text = "Cảnh Giới: %s" % PlayerState.cultivationRealm
	spirit_energy_label.text = "Linh Khí: %d / %d" % [PlayerState.spiritEnergy, PlayerState.maxSpiritEnergy]
	
	var next_realm_index = PlayerState.currentRealmIndex + 1
	if next_realm_index < Database.realms.size():
		var next_realm_info = Database.realms[next_realm_index]
		var required_cp = next_realm_info.requiredCp
		breakthrough_button.text = "Đột Phá (%.0f Tu Vi)" % required_cp
		breakthrough_button.disabled = PlayerState.cultivationPoints < required_cp
	else:
		breakthrough_button.text = "Đã Tới Đỉnh Cao"
		breakthrough_button.disabled = true


# Hàm này sẽ được gọi mỗi khi CultivateButton được nhấn.
func _on_cultivate_button_pressed() -> void:
	# Chỉ cho phép tu luyện nếu còn đủ Linh Khí (ví dụ: cần 5 Linh Khí)
	if PlayerState.spiritEnergy >= 5:
		PlayerState.spiritEnergy -= 5
		PlayerState.cultivationPoints += 1.5
		update_stats_display()
	else:
		print("Linh khí đã cạn kiệt, không thể tu luyện!")


# Hàm này được gọi mỗi khi RestButton được nhấn.
func _on_rest_button_pressed() -> void:
	# Mỗi lần nghỉ ngơi hồi phục 15 Linh Khí
	PlayerState.spiritEnergy += 15
	PlayerState.spiritEnergy = min(PlayerState.spiritEnergy, PlayerState.maxSpiritEnergy)
	update_stats_display()
	

func _on_breakthrough_button_pressed() -> void:
	if PlayerState.attempt_breakthrough():
		print("Đột phá thành công lên cảnh giới mới!")
	update_stats_display()
	
	
# Hàm được gọi khi nhấn nút Khiêu Chiến
func _on_challenge_button_pressed() -> void:
	# Tải dữ liệu của kẻ địch từ file .tres
	var enemy_to_fight = load("res://data/enemies/rival_disciple.tres")
	
	if enemy_to_fight:
		main_ui.hide() # Ẩn giao diện chính
		# Bắt đầu trận đấu, truyền dữ liệu kẻ địch vào
		combat_scene.start_combat(enemy_to_fight)
	else:
		print("Không tìm thấy dữ liệu kẻ địch!")
