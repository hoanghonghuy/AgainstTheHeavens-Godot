# cultivation_method_ui.gd
extends Control

signal closed

#== THAM CHIẾU NODE ==
@onready var method_list_container: VBoxContainer = %MethodListContainer
@onready var method_name_label: Label = %MethodNameLabel
@onready var method_rank_label: Label = %MethodRankLabel
@onready var method_description_label: Label = %MethodDescriptionLabel
@onready var effects_container: VBoxContainer = %EffectsContainer
@onready var activate_button: Button = %ActivateButton
@onready var close_button: Button = %CloseButton

var selected_method: CultivationMethodData = null

func _ready() -> void:

	self.hide()

func open_panel():
	self.show()
	_update_all_displays()

func _on_close_button_pressed():
	self.hide()
	closed.emit()

func _update_all_displays():
	_populate_method_list()
	
	# Mặc định chọn công pháp đang kích hoạt
	if selected_method == null:
		selected_method = Database.cultivation_methods.get(PlayerState.activeCultivationMethodId)
		
	_display_method_details()

func _populate_method_list():
	for child in method_list_container.get_children():
		child.queue_free()
	
	for method_id in PlayerState.learnedCultivationMethods:
		var method_data: CultivationMethodData = Database.cultivation_methods.get(method_id)
		if method_data:
			var button = Button.new()
			button.text = method_data.methodName
			button.pressed.connect(_on_method_selected.bind(method_data))
			method_list_container.add_child(button)

func _on_method_selected(method_data: CultivationMethodData):
	selected_method = method_data
	_display_method_details()

func _display_method_details():
	if selected_method == null: return

	method_name_label.text = selected_method.methodName
	method_rank_label.text = "Phẩm Giai: %s" % CultivationMethodData.MethodRank.keys()[selected_method.rank]
	method_description_label.text = selected_method.description
	
	for child in effects_container.get_children(): child.queue_free()
	for effect_key in selected_method.passiveEffects:
		var label = Label.new()
		var effect_value = selected_method.passiveEffects[effect_key]
		# Tạm thời vẫn dùng "Từ điển dịch thuật" đơn giản
		var effect_name = effect_key.replace("_", " ").capitalize()
		label.text = "- %s: +%s" % [effect_name, str(effect_value)]
		effects_container.add_child(label)
		
	# Vô hiệu hóa nút nếu công pháp đã được chọn đang được kích hoạt
	activate_button.disabled = (selected_method.id == PlayerState.activeCultivationMethodId)
	if activate_button.disabled:
		activate_button.text = "Đang Tu Luyện"
	else:
		activate_button.text = "Bắt Đầu Tu Luyện"

func _on_activate_button_pressed():
	if selected_method:
		PlayerState.activeCultivationMethodId = selected_method.id
		print("Đã đổi công pháp tu luyện thành: ", selected_method.methodName)
		# Cập nhật lại giao diện để nút bấm bị vô hiệu hóa
		_display_method_details()
