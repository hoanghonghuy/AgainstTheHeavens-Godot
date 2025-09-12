extends Node

var game_data_resource: GameData

var realms: Array[RealmData]
var skills: Dictionary = {}
var items: Dictionary = {}

func _ready() -> void:
	game_data_resource = load("res://data/game_data.tres")
	
	if game_data_resource:
		# Tải dữ liệu cảnh giới
		realms = game_data_resource.realms
		
		# Tải và xử lý dữ liệu kỹ năng
		for skill_data in game_data_resource.skills:
			if skill_data and not skill_data.skillId.is_empty():
				if not skills.has(skill_data.skillId):
					skills[skill_data.skillId] = skill_data
				else:
					print("Cảnh báo: Trùng lặp Skill ID '%s'" % skill_data.skillId)
		
		# Tải và xử lý dữ liệu vật phẩm
		for item_data in game_data_resource.items:
			if item_data and not item_data.id.is_empty():
				if not items.has(item_data.id):
					items[item_data.id] = item_data
				else:
					print("Cảnh báo: Trùng lặp Item ID '%s'" % item_data.id)

		print("Cơ sở dữ liệu game đã được tải thành công! (%d cảnh giới, %d kỹ năng, %d vật phẩm)" % [realms.size(), skills.size(), items.size()])
	else:
		print("LỖI NGHIÊM TRỌNG: KHÔNG THỂ TẢI FILE 'res://data/game_data.tres'!")
