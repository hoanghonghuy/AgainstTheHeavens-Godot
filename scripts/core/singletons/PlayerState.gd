# PlayerState.gd
# Singleton này lưu trữ toàn bộ trạng thái và tiến trình của người chơi.
# Có thể truy cập từ bất kỳ đâu bằng cách gọi PlayerState.variable_name
extends Node

# Sẽ được phát ra mỗi khi một chỉ số được cập nhật bởi hiệu ứng.
signal stats_changed

# Biến theo dõi vị trí của người chơi trong danh sách cảnh giới
var currentRealmIndex: int = 0

#== Primary Stats (Chỉ Số Cơ Bản) ==
var cultivationPoints: float = 0.0 # Điểm tu vi, tương tự EXP.
var spiritEnergy: float = 50.0        # Năng lượng tâm linh, tương tự Mana.
var maxSpiritEnergy: int = 100     # Giới hạn năng lượng tâm linh tối đa.
var healthPoints: int = 100        # Điểm sinh mệnh, tương tự HP.
var spiritStones: int = 10         # Đơn vị tiền tệ chính.

#== Attribute Stats (Chỉ Số Phẩm Chất) ==
# Ảnh hưởng đến khả năng vượt qua nghịch cảnh, đột phá, lĩnh ngộ...
var patience: int = 5
var fortitude: int = 5
var comprehension: int = 5

#== Combat Stats (Chỉ Số Chiến Đấu) ==
var attackPower: int = 10
var defense: int = 5
var agility: int = 5
var speed: int = 5

#== Core Properties (Thuộc Tính Cốt Lõi) ==
# Sẽ được thiết lập khi bắt đầu game.
var spiritRoot: String = "Ngũ Hành Tạp Linh Căn" # Ví dụ: "Thiên Linh Căn (Kim)"
var cultivationRealm: String = "Luyện Khí Kỳ Tầng Một"

#== Inventories (Túi Đồ) ==
# Chúng ta sẽ sử dụng Dictionary để lưu trữ.
# Key: ID của vật phẩm, Value: số lượng.
var inventory: Dictionary = {"item_basic_healing_pill": 5}
var equipment: Dictionary = {} # Ví dụ: {"weapon": "item_thiet_kiem"}

#== Skills (Kỹ Năng Đã Học) ==
# Mảng này sẽ chứa ID của các kỹ năng đã học.
# cho nhân vật biết "Hỏa Cầu Thuật" ngay từ đầu để tiện cho việc thử nghiệm.
var learnedSkills: Array = ["skill_fireball"]

#== Recipes (Công Thức Đã Biết) ==
var learnedRecipes: Array = ["recipe_basic_healing_pill"]

#== Quests (Nhiệm Vụ) ==
# Dictionary này sẽ lưu tiến trình của các nhiệm vụ đang hoạt động.
# Key: Quest ID (ví dụ: "quest_first_steps")
# Value: Một Dictionary khác chứa tiến trình của từng mục tiêu.
# Ví dụ: { "quest_first_steps": { "craft_item_basic_healing_pill": 0 } }
var quest_progress: Dictionary = {}

#== Cave Mansion (Động Phủ) ==
# Dictionary này sẽ lưu cấp bậc hiện tại của các công trình.
# Key: Building ID (ví dụ: "spirit_gathering_array")
# Value: Cấp bậc hiện tại (ví dụ: 1)
# khởi tạo Tụ Linh Trận ở cấp 1 cho người chơi.
var building_levels: Dictionary = {
	"spirit_gathering_array": 1
}

func attempt_breakthrough() -> bool:
	var next_realm_index = currentRealmIndex + 1
	if next_realm_index >= Database.realms.size():
		print("Đã đạt cảnh giới tối đa!")
		return false
	
	var next_realm_info = Database.realms[next_realm_index]
	
	if cultivationPoints >= next_realm_info.requiredCp:
		print("Đột phá thành công!")
		cultivationPoints -= next_realm_info.requiredCp
		
		currentRealmIndex = next_realm_index
		cultivationRealm = next_realm_info.realmName
		
		# Nhận phần thưởng mới
		maxSpiritEnergy += next_realm_info.bonusMaxSe
		attackPower += next_realm_info.bonusAttack
		defense += next_realm_info.bonusDefense
		
		spiritEnergy = maxSpiritEnergy
		
		return true
	else:
		print("Tu vi chưa đủ, không thể đột phá.")
		return false

# Hàm để tiếp nhận một nhiệm vụ mới
func accept_quest(quest_id: String):
	# Kiểm tra xem nhiệm vụ đã tồn tại chưa để tránh nhận lại
	if quest_progress.has(quest_id):
		print("Đã nhận nhiệm vụ này rồi.")
		return

	var quest_data: QuestData = Database.quests.get(quest_id)
	if not quest_data:
		print("Lỗi: Không tìm thấy dữ liệu cho quest ID: ", quest_id)
		return

	# Tạo một mục mới cho nhiệm vụ trong quest_progress
	var new_quest_entry = {}
	# Khởi tạo tiến trình cho tất cả các mục tiêu về 0
	for objective in quest_data.objectives:
		var progress_id = "%s_%s" % [objective["type"], objective["target_id"]]
		new_quest_entry[progress_id] = 0

	quest_progress[quest_id] = new_quest_entry
	print("Đã nhận nhiệm vụ mới: ", quest_data.title)
	
#  Được gọi mỗi khung hình.
# "delta" là khoảng thời gian (tính bằng giây) trôi qua từ khung hình trước.
func _process(delta: float) -> void:
	var stats_did_change = false # Biến cờ để kiểm tra xem có gì thay đổi không
	
	# 1. Lấy ra các công trình mà người chơi đang sở hữu
	for building_id in building_levels:
		var current_level = building_levels[building_id]
		# Lấy dữ liệu của cấp hiện tại từ Database
		var level_data: BuildingData = Database.buildings[building_id][current_level - 1]
		
		# 2. Lặp qua các hiệu ứng của công trình đó
		for effect_key in level_data.effects:
			var effect_value = level_data.effects[effect_key]
			
			# 3. Áp dụng hiệu ứng tương ứng
			if effect_key == "spirit_energy_regen":
				# Chỉ hồi phục nếu Linh Khí chưa đầy
				if spiritEnergy < maxSpiritEnergy:
					spiritEnergy += effect_value * delta # Cộng thêm lượng hồi phục mỗi giây
					# Đảm bảo không vượt quá giới hạn
					spiritEnergy = min(spiritEnergy, maxSpiritEnergy)
					stats_did_change = true
			
			# (Sau này có thể thêm các hiệu ứng khác ở đây, ví dụ sản xuất Linh Thảo)
			# if effect_key == "spirit_grass_yield": ...
	
	# 4. Nếu có bất kỳ chỉ số nào thay đổi, hãy phát tín hiệu
	if stats_did_change:
		stats_changed.emit()
