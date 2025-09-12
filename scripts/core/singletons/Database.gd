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

# Hàm _ready() được gọi một lần khi game bắt đầu, sau khi tất cả các node được tải.
# Đây là nơi hoàn hảo để nạp toàn bộ dữ liệu.
func _ready() -> void:
	# Tải trực tiếp file resource trung tâm bằng code để đảm bảo sự ổn định
	game_data_resource = load("res://data/game_data.tres")
	
	if game_data_resource:
		# 1. Tải dữ liệu Cảnh Giới (dưới dạng một danh sách có thứ tự)
		realms = game_data_resource.realms
		
		# 2. Tải và xử lý dữ liệu Kỹ Năng (chuyển thành từ điển)
		for skill_data in game_data_resource.skills:
			if skill_data and not skill_data.skillId.is_empty():
				if not skills.has(skill_data.skillId):
					skills[skill_data.skillId] = skill_data
				else:
					print("Cảnh báo Database: Trùng lặp Skill ID '%s'" % skill_data.skillId)
		
		# 3. Tải và xử lý dữ liệu Vật Phẩm (chuyển thành từ điển)
		for item_data in game_data_resource.items:
			if item_data and not item_data.id.is_empty():
				if not items.has(item_data.id):
					items[item_data.id] = item_data
				else:
					print("Cảnh báo Database: Trùng lặp Item ID '%s'" % item_data.id)
		
		# 4. Tải và xử lý dữ liệu NPC (chuyển thành từ điển)
		for npc_data in game_data_resource.npcs:
			if npc_data and not npc_data.npcId.is_empty():
				if not npcs.has(npc_data.npcId):
					npcs[npc_data.npcId] = npc_data
				else:
					print("Cảnh báo Database: Trùng lặp NPC ID '%s'" % npc_data.npcId)

		# In ra thông báo tổng kết để xác nhận mọi thứ hoạt động
		print("Cơ sở dữ liệu game đã được tải thành công! (%d cảnh giới, %d kỹ năng, %d vật phẩm, %d NPC)" % [realms.size(), skills.size(), items.size(), npcs.size()])
	else:
		# Lỗi này chỉ xảy ra nếu file game_data.tres bị xóa hoặc đổi tên
		print("LỖI NGHIÊM TRỌNG: KHÔNG THỂ TẢI FILE 'res://data/game_data.tres'!")
