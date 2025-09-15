# enemy.gd
# Script này chỉ dành riêng cho các kẻ địch trong thế giới.
extends Area2D

# Tín hiệu này sẽ được phát ra khi người chơi muốn bắt đầu chiến đấu.
signal combat_initiated(enemy_data: EnemyData)

@export var enemy_data: EnemyData
@onready var sprite: Sprite2D = %Sprite

func _ready() -> void:
	if enemy_data:
		sprite.texture = enemy_data.sprite

	self.input_event.connect(_on_input_event)

func _on_input_event(viewport, event: InputEvent, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if enemy_data:
			# Phát ra tín hiệu chuyên dụng cho việc chiến đấu.
			combat_initiated.emit(enemy_data)
