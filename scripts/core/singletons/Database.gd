# Database.gd
# Singleton này là kho tàng tri thức của thế giới game,
# chịu trách nhiệm tải và cung cấp toàn bộ dữ liệu tĩnh (không thay đổi).
extends Node

# Biến để lưu trữ toàn bộ dữ liệu game sau khi tải từ file
var game_data_resource: GameData

# Các biến công khai để các script khác có thể truy cập dễ dàng
var realms: Array[RealmData]     # Danh sách các cảnh giới theo thứ tự
var skills: Dictionary = {}        # Từ điển tra cứu Kỹ Năng bằng ID
var items: Dictionary = {}         # Từ điển tra cứu Vật Phẩm bằng ID
var npcs: Dictionary = {}          # Từ điển tra cứu NPC bằng ID
var recipes: Dictionary = {}       # Từ điển tra cứu Công Thức bằng ID
var quests: Dictionary = {}
var buildings: Dictionary = {}

# Hàm _ready() được gọi một lần khi game bắt đầu, sau khi tất cả các node được tải.
# Đây là nơi hoàn hảo để nạp toàn bộ dữ liệu.
func _ready() -> void:
	# Tải trực tiếp file resource trung tâm bằng code để đảm bảo sự ổn định
	game_data_resource = load("res://data/game_data.tres")
	
	if game_data_resource:
		# 1. Tải dữ liệu Cảnh Giới
		realms = game_data_resource.realms
		
		# 2. Tải và xử lý dữ liệu Kỹ Năng
		for skill_data in game_data_resource.skills:
			if skill_data and not skill_data.skillId.is_empty():
				if not skills.has(skill_data.skillId):
					skills[skill_data.skillId] = skill_data
				else:
					print("Cảnh báo Database: Trùng lặp Skill ID '%s'" % skill_data.skillId)
		
		# 3. Tải và xử lý dữ liệu Vật Phẩm
		for item_data in game_data_resource.items:
			if item_data and not item_data.id.is_empty():
				if not items.has(item_data.id):
					items[item_data.id] = item_data
				else:
					print("Cảnh báo Database: Trùng lặp Item ID '%s'" % item_data.id)
		
		# 4. Tải và xử lý dữ liệu NPC
		for npc_data in game_data_resource.npcs:
			if npc_data and not npc_data.npcId.is_empty():
				if not npcs.has(npc_data.npcId):
					npcs[npc_data.npcId] = npc_data
				else:
					print("Cảnh báo Database: Trùng lặp NPC ID '%s'" % npc_data.npcId)
		
		# 5. Tải và xử lý dữ liệu Công Thức
		for recipe_data in game_data_resource.recipes:
			if recipe_data and not recipe_data.recipeId.is_empty():
				if not recipes.has(recipe_data.recipeId):
					recipes[recipe_data.recipeId] = recipe_data
				else:
					print("Cảnh báo Database: Trùng lặp Recipe ID '%s'" % recipe_data.recipeId)
		
		# 6. Tải và xử lý dữ liệu Nhiệm Vụ
		for quest_data in game_data_resource.quests:
			if quest_data and not quest_data.questId.is_empty():
				if not quests.has(quest_data.questId):
					quests[quest_data.questId] = quest_data
				else:
					print("Cảnh báo Database: Trùng lặp Quest ID '%s'" % quest_data.questId)
					
		# 7. Tải và xử lý dữ liệu Công Trình Động Phủ
		buildings = game_data_resource.buildings
		
		# In ra thông báo tổng kết để xác nhận mọi thứ hoạt động
		print("Cơ sở dữ liệu game đã được tải thành công! (%d cảnh giới, %d kỹ năng, %d vật phẩm, %d NPC, %d công thức, %d nhiệm vụ)" % [realms.size(), skills.size(), items.size(), npcs.size(), recipes.size(), quests.size()])
	else:
		print("LỖI NGHIÊM TRỌNG: KHÔNG THỂ TẢI FILE 'res://data/game_data.tres'!")
