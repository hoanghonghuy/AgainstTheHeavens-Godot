# quest_log_ui.gd
extends Control

# Tín hiệu báo cho MainScene biết người chơi muốn đóng giao diện này
signal closed

#== THAM CHIẾU ĐẾN CÁC NODE GIAO DIỆN ==
# Cột Trái
@onready var quest_list_container: VBoxContainer = %QuestListContainer
# Cột Phải
@onready var quest_title_label: Label = %QuestTitleLabel
@onready var quest_description_label: Label = %QuestDescriptionLabel
@onready var objectives_container: VBoxContainer = %ObjectivesContainer
@onready var rewards_container: VBoxContainer = %RewardsContainer
# Nút Đóng
@onready var close_button: Button = %CloseButton

# Biến để lưu trữ nhiệm vụ đang được chọn
var selected_quest: QuestData = null

func _ready() -> void:
	self.hide()

# Hàm này sẽ được gọi từ MainScene để mở giao diện
func open_panel():
	self.show()
	# Cập nhật toàn bộ giao diện với dữ liệu mới nhất
	_update_display()

func _on_close_button_pressed():
	self.hide()
	closed.emit()

#====================================================#
#               LOGIC HIỂN THỊ CHÍNH                  #
#====================================================#

# Hàm tổng hợp để cập nhật toàn bộ giao diện
func _update_display():
	_populate_quest_list()
	
	# Nếu chưa có nhiệm vụ nào được chọn, mặc định chọn nhiệm vụ đầu tiên
	if selected_quest == null and not PlayerState.quest_progress.is_empty():
		var first_quest_id = PlayerState.quest_progress.keys()[0]
		selected_quest = Database.quests.get(first_quest_id)
		
	_display_quest_details()

# CỘT TRÁI: Tạo danh sách các nút nhiệm vụ
func _populate_quest_list():
	for child in quest_list_container.get_children():
		child.queue_free()
	
	for quest_id in PlayerState.quest_progress:
		var quest_data: QuestData = Database.quests.get(quest_id)
		if quest_data:
			var quest_button = Button.new()
			quest_button.text = quest_data.title
			quest_button.pressed.connect(_on_quest_selected.bind(quest_data))
			quest_list_container.add_child(quest_button)

func _on_quest_selected(quest_data: QuestData):
	selected_quest = quest_data
	_display_quest_details()

# CỘT PHẢI: Hiển thị chi tiết nhiệm vụ được chọn
func _display_quest_details():
	# Xóa sạch dữ liệu cũ
	for child in objectives_container.get_children(): child.queue_free()
	for child in rewards_container.get_children(): child.queue_free()

	if selected_quest == null:
		quest_title_label.text = "Chưa nhận nhiệm vụ nào"
		quest_description_label.text = ""
		return

	# Hiển thị thông tin cơ bản
	quest_title_label.text = selected_quest.title
	quest_description_label.text = selected_quest.description
	
	# Hiển thị mục tiêu
	for objective in selected_quest.objectives:
		var progress_id = "%s_%s" % [objective["type"], objective["target_id"]]
		var current_progress = PlayerState.quest_progress[selected_quest.questId].get(progress_id, 0)
		var target_quantity = objective["quantity"]
		
		var objective_text = "Lỗi: Không rõ mục tiêu"
		if objective["type"] == "craft":
			var item_name = Database.items.get(objective["target_id"]).itemName
			# Dùng int() để ép kiểu, đảm bảo an toàn
			objective_text = "Luyện chế %s: %d / %d" % [item_name, int(current_progress), int(target_quantity)]
		
		var label = Label.new()
		label.text = objective_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		objectives_container.add_child(label)
		
	# Hiển thị phần thưởng
	for reward_key in selected_quest.rewards:
		var reward_value = selected_quest.rewards[reward_key]
		var reward_text = ""
		
		if reward_key == "cp":
			# SỬA LẠI: Dùng %.0f để xử lý đúng số thực
			reward_text = "- Tu Vi: %.0f" % reward_value
		elif reward_key == "spirit_stones":
			reward_text = "- Linh Thạch: %d" % int(reward_value)
		else: # Giả định là một vật phẩm
			var item_name = Database.items.get(reward_key).itemName
			reward_text = "- %s x%d" % [item_name, int(reward_value)]
			
		var label = Label.new()
		label.text = reward_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		rewards_container.add_child(label)
		
	# Hiển thị phần thưởng
	for reward_key in selected_quest.rewards:
		var reward_value = selected_quest.rewards[reward_key]
		var reward_text = ""
		
		if reward_key == "cp":
			reward_text = "- Tu Vi: %.0f" % reward_value
		elif reward_key == "spirit_stones":
			reward_text = "- Linh Thạch: %d" % reward_value
		else: # Giả định là một vật phẩm
			var item_name = Database.items.get(reward_key).itemName
			reward_text = "- %s x%d" % [item_name, reward_value]
			
		var label = Label.new()
		label.text = reward_text
		rewards_container.add_child(label)
