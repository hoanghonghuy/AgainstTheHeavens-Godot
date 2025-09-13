# dialogue_ui.gd
extends PanelContainer

signal close_requested
signal option_selected(option_data: Dictionary)

@onready var name_label: Label = %NameLabel
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var options_container: VBoxContainer = %OptionsContainer

var dialogue_pages: Array = []
var current_page_index: int = 0
var is_revealing_text: bool = false
var text_tween: Tween

func _ready() -> void:
	self.hide()
	self.gui_input.connect(_on_gui_input)

func start_dialogue(pages: Array):
	if pages.is_empty():
		print("Lỗi DialogueUI: Cố gắng bắt đầu hội thoại với danh sách trang rỗng!")
		return
		
	dialogue_pages = pages
	current_page_index = 0
	self.show()
	_show_current_page()

func end_dialogue():
	if text_tween and text_tween.is_running():
		text_tween.kill()
	self.hide()

func _show_current_page():
	var page = dialogue_pages[current_page_index]
	
	if page.has("speaker"):
		name_label.text = page["speaker"]
	
	# Dọn dẹp các lựa chọn cũ trước khi hiển thị trang mới
	for child in options_container.get_children():
		child.queue_free()
	
	# Kiểm tra và hiển thị text
	if page.has("text"):
		var full_text = page["text"]
		dialogue_text.text = full_text
		_reveal_text(full_text)
	else:
		# Nếu trang không có text (chỉ có options), bỏ qua hiệu ứng
		dialogue_text.text = ""
		_on_reveal_finished()

func _reveal_text(full_text: String):
	is_revealing_text = true
	if text_tween and text_tween.is_running():
		text_tween.kill()
	
	dialogue_text.visible_characters = 0
	
	text_tween = create_tween()
	text_tween.tween_property(dialogue_text, "visible_characters", full_text.length(), full_text.length() * 0.05)
	text_tween.finished.connect(_on_reveal_finished)

func _on_reveal_finished():
	is_revealing_text = false
	# Sau khi chữ chạy xong, mới hiển thị các lựa chọn (nếu có)
	_show_options_for_current_page()
	
func _show_options_for_current_page():
	var page = dialogue_pages[current_page_index]
	if page.has("options"):
		for option_data in page["options"]:
			var option_button = Button.new()
			option_button.text = option_data["text"]
			option_button.pressed.connect(_on_option_button_pressed.bind(option_data))
			options_container.add_child(option_button)

func _on_option_button_pressed(option_data: Dictionary):
	option_selected.emit(option_data)

func handle_click():
	if is_revealing_text:
		if text_tween and text_tween.is_running():
			text_tween.kill()
		dialogue_text.visible_characters = len(dialogue_pages[current_page_index].get("text", ""))
		_on_reveal_finished()
	else:
		if not dialogue_pages[current_page_index].has("options"):
			current_page_index += 1
			if current_page_index < dialogue_pages.size():
				_show_current_page()
			else:
				close_requested.emit()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		handle_click()
