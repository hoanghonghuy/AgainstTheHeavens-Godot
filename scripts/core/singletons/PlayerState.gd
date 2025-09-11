# PlayerState.gd
# Singleton này lưu trữ toàn bộ trạng thái và tiến trình của người chơi.
# Có thể truy cập từ bất kỳ đâu bằng cách gọi PlayerState.variable_name
extends Node

# Biến theo dõi vị trí của người chơi trong danh sách cảnh giới
var currentRealmIndex: int = 0

#== Primary Stats (Chỉ Số Cơ Bản) ==
var cultivationPoints: float = 0.0 # Điểm tu vi, tương tự EXP.
var spiritEnergy: int = 50         # Năng lượng tâm linh, tương tự Mana.
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
var inventory: Dictionary = {} # Ví dụ: {"item_truc_co_dan": 5}
var equipment: Dictionary = {} # Ví dụ: {"weapon": "item_thiet_kiem"}

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
