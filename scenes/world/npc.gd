# npc.gd
extends Area2D

# Tín hiệu này sẽ gửi đi TOÀN BỘ dữ liệu của NPC.
signal interacted(npc_data: NPCData)

@export var npc_data: NPCData
@onready var sprite: Sprite2D = %Sprite

func _ready() -> void:
	if npc_data:
		sprite.texture = npc_data.sprite
	else:
		print("Cảnh báo: NPC tại vị trí ", global_position, " chưa được gán NPCData!")
	
	self.input_event.connect(_on_input_event)

func _on_input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if npc_data:
			# Gửi đi đối tượng dữ liệu đã được gán trong Inspector.
			interacted.emit(npc_data)
