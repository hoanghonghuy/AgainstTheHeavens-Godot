# SaveManager.gd (Đã sửa lỗi print)
extends Node

const SAVE_PATH = "user://savegame.json"

#====================================================#
#                      LƯU GAME                      #
#====================================================#
func save_game():
	var save_data = {}
	
	# Chỉ số cơ bản
	save_data["cultivationPoints"] = PlayerState.cultivationPoints
	save_data["spiritEnergy"] = PlayerState.spiritEnergy
	save_data["healthPoints"] = PlayerState.healthPoints
	save_data["spiritStones"] = PlayerState.spiritStones
	save_data["maxSpiritEnergy"] = PlayerState.maxSpiritEnergy
	
	# Chỉ số phẩm chất
	save_data["patience"] = PlayerState.patience
	save_data["fortitude"] = PlayerState.fortitude
	save_data["comprehension"] = PlayerState.comprehension
	
	# Chỉ số chiến đấu
	save_data["attackPower"] = PlayerState.attackPower
	save_data["defense"] = PlayerState.defense
	save_data["agility"] = PlayerState.agility
	save_data["speed"] = PlayerState.speed
	
	# Thuộc tính cốt lõi
	save_data["currentRealmIndex"] = PlayerState.currentRealmIndex
	
	# Túi đồ & Kỹ năng
	save_data["inventory"] = PlayerState.inventory
	save_data["equipment"] = PlayerState.equipment
	save_data["learnedSkills"] = PlayerState.learnedSkills
	save_data["learnedRecipes"] = PlayerState.learnedRecipes
	save_data["quest_progress"] = PlayerState.quest_progress
	save_data["building_levels"] = PlayerState.building_levels
	
	# Ghi lại dấu thời gian hiện tại (tính bằng giây)
	save_data["last_saved_timestamp"] = Time.get_unix_time_from_system()

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("LỖI: Không thể mở file để lưu!")
		return

	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Lưu game thành công tại đường dẫn: ", SAVE_PATH)

#====================================================#
#                      TẢI GAME                      #
#====================================================#
func load_game():
	# 1. Đầu tiên, kiểm tra xem file save có tồn tại không.
	if not has_save_file():
		print("Không tìm thấy file lưu!")
		return # Không làm gì cả nếu không có file

	# 2. Mở file để đọc dữ liệu.
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("LỖI: Không thể mở file để tải!")
		return

	# 3. Đọc toàn bộ nội dung của file dưới dạng một chuỗi văn bản.
	var json_string = file.get_as_text()
	
	# 4. Đóng file lại ngay sau khi đọc xong.
	file.close()
	
	# 5. Chuyển đổi chuỗi JSON trở lại thành một đối tượng Godot (Dictionary).
	#    JSON.parse() sẽ trả về một Variant, chúng ta cần kiểm tra nó.
	var parse_result = JSON.parse_string(json_string)
	
	if parse_result == null:
		print("LỖI: Dữ liệu trong file save bị hỏng, không thể đọc được.")
		return
		
	# 6. Gán dữ liệu đã tải vào một biến Dictionary.
	var save_data = parse_result as Dictionary
	
	# 7. Lần lượt "ghi đè" các giá trị đã tải vào PlayerState.
	#    Dùng .get(key, default_value) để an toàn hơn, nếu một key nào đó
	#    không có trong file save, nó sẽ dùng giá trị mặc định thay vì crash game.
	
	# Chỉ số cơ bản
	PlayerState.cultivationPoints = save_data.get("cultivationPoints", 0.0)
	PlayerState.spiritEnergy = save_data.get("spiritEnergy", 50)
	PlayerState.healthPoints = save_data.get("healthPoints", 100)
	PlayerState.spiritStones = save_data.get("spiritStones", 10)
	PlayerState.maxSpiritEnergy = save_data.get("maxSpiritEnergy", 100)
	
	# Chỉ số phẩm chất
	PlayerState.patience = save_data.get("patience", 5)
	PlayerState.fortitude = save_data.get("fortitude", 5)
	PlayerState.comprehension = save_data.get("comprehension", 5)
	
	# Chỉ số chiến đấu
	PlayerState.attackPower = save_data.get("attackPower", 10)
	PlayerState.defense = save_data.get("defense", 5)
	PlayerState.agility = save_data.get("agility", 5)
	PlayerState.speed = save_data.get("speed", 5)
	
	# Thuộc tính cốt lõi
	PlayerState.currentRealmIndex = save_data.get("currentRealmIndex", 0)
	# Cập nhật lại tên cảnh giới từ Database
	if PlayerState.currentRealmIndex < Database.realms.size():
		PlayerState.cultivationRealm = Database.realms[PlayerState.currentRealmIndex].realmName
	
	# Túi đồ & Kỹ năng
	PlayerState.inventory = save_data.get("inventory", {})
	PlayerState.equipment = save_data.get("equipment", {})
	PlayerState.learnedSkills = save_data.get("learnedSkills", ["skill_fireball"])
	PlayerState.learnedRecipes = save_data.get("learnedRecipes", [])
	PlayerState.quest_progress = save_data.get("quest_progress", {})
	PlayerState.building_levels = save_data.get("building_levels", {
		"spirit_gathering_array": 1 # Giá trị mặc định nếu không tìm thấy
	})
	
	# === BẮT ĐẦU KHỐI LOGIC "TU LUYỆN NGOẠI TUYẾN" (MỚI) ===
	var last_saved_time = save_data.get("last_saved_timestamp", 0)
	if last_saved_time > 0:
		var current_time = Time.get_unix_time_from_system()
		var time_passed_offline = current_time - last_saved_time
		
		print("Thời gian offline: %d giây." % time_passed_offline)
		
		var total_spirit_energy_gained = 0.0
		
		# Tính toán tổng tài nguyên nhận được từ các công trình
		for building_id in PlayerState.building_levels:
			var current_level = PlayerState.building_levels[building_id]
			var level_data: BuildingData = Database.buildings[building_id][current_level - 1]
			
			for effect_key in level_data.effects:
				var effect_value = level_data.effects[effect_key]
				if effect_key == "spirit_energy_regen":
					total_spirit_energy_gained += effect_value * time_passed_offline
		
		# Cộng tài nguyên vào cho người chơi
		if total_spirit_energy_gained > 0:
			PlayerState.spiritEnergy += total_spirit_energy_gained
			# Đảm bảo không vượt quá giới hạn
			PlayerState.spiritEnergy = min(PlayerState.spiritEnergy, PlayerState.maxSpiritEnergy)
			print("Đã nhận được %.1f Linh Khí từ tu luyện ngoại tuyến." % total_spirit_energy_gained)
			
	# === KẾT THÚC KHỐI LOGIC "TU LUYỆN NGOẠI TUYẾN" ===
	
	print("Tải game thành công!")

#====================================================#
#                    KIỂM TRA FILE                   #
#====================================================#
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
