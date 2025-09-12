# res://scenes/ui/dialogue_ui.gd
# Script này chỉ chịu trách nhiệm hiển thị hội thoại và hiệu ứng chữ chạy.
extends PanelContainer

# Tín hiệu này sẽ báo cho MainScene biết người chơi muốn đóng hộp thoại.
signal close_requested

@onready var name_label: Label = %NameLabel
@onready var dialogue_text: RichTextLabel = %DialogueText

var dialogue_pages: Array = []
var current_page_index: int = 0
var is_revealing_text: bool = false
var text_tween: Tween

func _ready() -> void:
	self.hide()
	# Kết nối tín hiệu input của chính Panel này để xử lý click bên trong hộp thoại.
	self.gui_input.connect(_on_gui_input)

# Hàm được gọi từ MainScene để bắt đầu hội thoại.
func start_dialogue(pages: Array):
	if pages.is_empty():
		print("Lỗi: Cố gắng bắt đầu hội thoại với danh sách trang rỗng!")
		return
		
	dialogue_pages = pages
	current_page_index = 0
	self.show()
	_show_current_page()

# Hàm để đóng và dọn dẹp hộp thoại, được gọi bởi MainScene.
func end_dialogue():
	if text_tween and text_tween.is_running():
		text_tween.kill()
	self.hide()

# Hàm hiển thị trang hội thoại hiện tại.
func _show_current_page():
	var page = dialogue_pages[current_page_index]
	
	if page.has("speaker"):
		name_label.text = page["speaker"]
	
	var full_text = page["text"]
	
	# Gán nội dung mới vào RichTextLabel.
	dialogue_text.text = full_text
	
	# Bắt đầu hiệu ứng chữ chạy.
	_reveal_text(full_text)

# Hàm tạo hiệu ứng chữ chạy bằng Tween.
func _reveal_text(full_text: String):
	is_revealing_text = true
	if text_tween and text_tween.is_running():
		text_tween.kill()
	
	dialogue_text.visible_characters = 0
	
	text_tween = create_tween()
	text_tween.tween_property(dialogue_text, "visible_characters", full_text.length(), full_text.length() * 0.05)
	text_tween.finished.connect(func(): is_revealing_text = false)

# Hàm trung tâm xử lý logic khi có click.
func handle_click():
	# Nếu chữ đang chạy -> hiện ra hết ngay lập tức.
	if is_revealing_text:
		if text_tween and text_tween.is_running():
			text_tween.kill()
		dialogue_text.visible_characters = len(dialogue_pages[current_page_index]["text"])
		is_revealing_text = false
	# Nếu chữ đã hiện ra hết...
	else:
		# ...thì chuyển sang trang tiếp theo.
		current_page_index += 1
		if current_page_index < dialogue_pages.size():
			_show_current_page()
		# Nếu đã hết trang, phát tín hiệu yêu cầu đóng.
		else:
			close_requested.emit()

# Hàm được gọi khi có tương tác chuột trên PanelContainer này.
func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		handle_click()
