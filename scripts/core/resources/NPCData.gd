# NPCData.gd
class_name NPCData
extends Resource

@export var npcId: String = ""
@export var npcName: String = "Tên NPC"
@export var sprite: Texture2D

# Mỗi phần tử trong Array này sẽ là một Dictionary, đại diện cho một câu thoại.
@export var dialogue_pages: Array = []
