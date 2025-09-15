# res://scripts/core/resources/NPCData.gd
class_name NPCData
extends Resource

@export var npcId: String = ""
@export var npcName: String = "Tên NPC"
@export var sprite: Texture2D

# Dùng Dictionary để lưu nhiều kịch bản hội thoại
# Key: Tên kịch bản (ví dụ: "default", "quest_inprogress", "quest_complete")
# Value: Mảng các trang hội thoại (Array of Dictionaries)
@export var dialogue_scripts: Dictionary = {}
