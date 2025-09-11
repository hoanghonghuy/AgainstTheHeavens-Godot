@tool
extends Node

#=========================================================================#
#                  CÔNG CỤ TẠO DỮ LIỆU CẢNH GIỚI TIÊN NGHỊCH               #
#=========================================================================#
# HƯỚNG DẪN:                                                              #
# 1. Nhấn tick "Clear All Realm Files" để dọn dẹp dữ liệu cũ (rồi bỏ tick). #
# 2. Nhấn tick "GENERATE ALL REALMS" để tạo toàn bộ cảnh giới.             #
# 3. Mở file "res://data/game_data.tres" và kéo các file mới vào.          #
#=========================================================================#

@export_group("Actions")
@export var GENERATE_ALL_REALMS: bool = false:
	set(value):
		if value: 
			_generate_all_realms()
			_update_game_data_file() # Tự động cập nhật sau khi tạo
			set_block_signals(true) # Ngăn việc chạy lại liên tục
			GENERATE_ALL_REALMS = false
			set_block_signals(false)

@export var clear_all_realm_files: bool = false:
	set(value):
		if value: 
			_clear_realm_files()
			set_block_signals(true)
			clear_all_realm_files = false
			set_block_signals(false)


const REALMS_FOLDER_PATH = "res://data/realms/"
const GAME_DATA_PATH = "res://data/game_data.tres"
var global_index: int = 0

# HÀM TỰ ĐỘNG CẬP NHẬT GAME_DATA.TRES
func _update_game_data_file():
	print("Bắt đầu cập nhật file game_data.tres...")
	
	# 1. Tải file game_data.tres vào bộ nhớ
	var game_data = load(GAME_DATA_PATH)
	if not game_data:
		print("Lỗi: Không tìm thấy file %s. Hãy tạo nó trước." % GAME_DATA_PATH)
		return
		
	# 2. Xóa sạch danh sách cảnh giới cũ trong file
	game_data.realms.clear()
	
	# 3. Lấy danh sách tất cả file .tres trong thư mục realms
	var realm_files = []
	var dir = DirAccess.open(REALMS_FOLDER_PATH)
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres"):
				realm_files.append(file_name)
	
	# Sắp xếp theo tên file để đảm bảo đúng thứ tự (realm_001, realm_002, ...)
	realm_files.sort()
	
	# 4. Tải từng file resource và thêm vào danh sách
	for file_name in realm_files:
		var file_path = REALMS_FOLDER_PATH.path_join(file_name)
		var realm_resource = load(file_path)
		if realm_resource:
			game_data.realms.append(realm_resource)
		else:
			print("Cảnh báo: Không thể tải file %s" % file_path)
			
	# 5. Lưu lại những thay đổi vào file game_data.tres
	var error = ResourceSaver.save(game_data, GAME_DATA_PATH)
	if error == OK:
		print("CẬP NHẬT THÀNH CÔNG! Đã thêm %d cảnh giới vào game_data.tres." % game_data.realms.size())
	else:
		print("Lỗi khi lưu file game_data.tres!")

func _clear_realm_files():
	var dir = DirAccess.open(REALMS_FOLDER_PATH)
	if dir:
		for file_name in dir.get_files():
			dir.remove(file_name)
		print("==========================================")
		print("ĐÃ XÓA TẤT CẢ FILE CẢNH GIỚI CŨ.")
		print("==========================================")

func _generate_all_realms():
	global_index = 0 # SỬA LỖI: Luôn reset chỉ số đếm khi bắt đầu
	DirAccess.make_dir_recursive_absolute(REALMS_FOLDER_PATH)
	print("Bắt đầu tạo dữ liệu cảnh giới...")
	
	#=== NHẤT BỘ TUNG HOÀNH ===
	_generate_NhatBo_LuyenKhi()
	_generate_NhatBo_TrucCo()
	_generate_NhatBo_KetDan()
	_generate_NhatBo_NguyenAnh()
	_generate_NhatBo_HoaThan()
	_generate_NhatBo_AnhBien()
	_generate_NhatBo_VanDinh()
	
	#=== GIAI ĐOẠN QUÁ ĐỘ LÊN NHỊ BỘ ===
	_generate_QuaDo_AmDuong()
	
	#=== NHỊ BỘ PHI THIÊN ===
	_generate_NhiBo_KbuyToai()
	
	#=== GIAI ĐOẠN QUÁ ĐỘ LÊN TAM BỘ ===
	_generate_QuaDo_ThienNhanSuy()
	
	#=== TAM BỘ VÔ BIÊN ===
	_generate_TamBo_KhongNiet()
	_generate_TamBo_KhongLinh()
	_generate_TamBo_KhongHuyen()
	_generate_TamBo_KhongKiep()
	_generate_TamBo_Ton()
	
	#=== GIAI ĐOẠN QUÁ ĐỘ LÊN TỨ BỘ ===
	_generate_QuaDo_DapThienKieu()
	
	#=== TỨ BỘ ĐẠP THIÊN ===
	_generate_TuBo_DapThien()
	
	print("==========================================")
	print("HOÀN TẤT! ĐÃ TẠO %d CẤP BẬC CẢNH GIỚI." % global_index)
	print("Nhớ cập nhật lại file game_data.tres!")
	print("==========================================")

#... (Phần thân các hàm tạo chi tiết giữ nguyên như code trước)

#-------------------------------------------------------------------
# CÁC HÀM TẠO CHI TIẾT
#-------------------------------------------------------------------
func _generate_NhatBo_LuyenKhi():
	for i in range(1, 16): # 15 tầng
		_create_realm_from_data("Luyện Khí Tầng %d" % i, "nhatbo_luyenkhi_%d" % i, round(50 * pow(1.5, i - 1)), 10 + (i * 2), 1 + floor(i / 3), floor(i / 5))

func _generate_NhatBo_TrucCo():
	_create_realm_from_data("Trúc Cơ Sơ Kỳ", "nhatbo_trucco_1", 20000, 150, 50, 25)
	_create_realm_from_data("Trúc Cơ Trung Kỳ", "nhatbo_trucco_2", 45000, 200, 70, 35)
	_create_realm_from_data("Trúc Cơ Hậu Kỳ", "nhatbo_trucco_3", 80000, 250, 100, 50)

func _generate_NhatBo_KetDan():
	_create_realm_from_data("Kết Đan Sơ Kỳ", "nhatbo_ketdan_1", 250000, 500, 250, 120)
	_create_realm_from_data("Kết Đan Trung Kỳ", "nhatbo_ketdan_2", 500000, 700, 350, 180)
	_create_realm_from_data("Kết Đan Hậu Kỳ", "nhatbo_ketdan_3", 900000, 1000, 500, 250)

func _generate_NhatBo_NguyenAnh():
	_create_realm_from_data("Nguyên Anh Sơ Kỳ", "nhatbo_nguyenanh_1", 2.5e6, 2500, 1200, 600)
	_create_realm_from_data("Nguyên Anh Trung Kỳ", "nhatbo_nguyenanh_2", 5e6, 3500, 1800, 900)
	_create_realm_from_data("Nguyên Anh Hậu Kỳ", "nhatbo_nguyenanh_3", 9e6, 5000, 2500, 1300)

func _generate_NhatBo_HoaThan():
	_create_realm_from_data("Hóa Thần Sơ Kỳ", "nhatbo_hoathan_1", 2e7, 10000, 5000, 2500)
	_create_realm_from_data("Hóa Thần Trung Kỳ", "nhatbo_hoathan_2", 5e7, 15000, 7500, 3800)
	_create_realm_from_data("Hóa Thần Hậu Kỳ", "nhatbo_hoathan_3", 9e7, 22000, 11000, 5500)

func _generate_NhatBo_AnhBien():
	_create_realm_from_data("Anh Biến Sơ Kỳ", "nhatbo_anhbien_1", 2e8, 50000, 25000, 12000)
	_create_realm_from_data("Anh Biến Trung Kỳ", "nhatbo_anhbien_2", 5e8, 75000, 38000, 19000)
	_create_realm_from_data("Anh Biến Hậu Kỳ", "nhatbo_anhbien_3", 9e8, 110000, 55000, 27000)

func _generate_NhatBo_VanDinh():
	_create_realm_from_data("Vấn Đỉnh Sơ Kỳ", "nhatbo_vandinh_1", 2e9, 250000, 120000, 60000)
	_create_realm_from_data("Vấn Đỉnh Trung Kỳ", "nhatbo_vandinh_2", 5e9, 380000, 180000, 90000)
	_create_realm_from_data("Vấn Đỉnh Hậu Kỳ", "nhatbo_vandinh_3", 9e9, 550000, 270000, 130000)

func _generate_QuaDo_AmDuong():
	_create_realm_from_data("Âm Hư", "quado_amhu_1", 2e10, 1000000, 500000, 250000)
	_create_realm_from_data("Dương Thực", "quado_duongthuc_2", 8e10, 2000000, 1000000, 500000)

func _generate_NhiBo_KbuyToai():
	_create_realm_from_data("Khuy Niết", "nhibo_khuyniet_1", 2e11, 5e6, 2.5e6, 1.2e6)
	_create_realm_from_data("Tịnh Niết", "nhibo_tinhniet_2", 8e11, 1e7, 5e6, 2.5e6)
	_create_realm_from_data("Toái Niết", "nhibo_toainiet_3", 2e12, 2e7, 1e7, 5e6)

func _generate_QuaDo_ThienNhanSuy():
	for i in range(1, 6):
		var cp = 5e12 * pow(2, i)
		var stat_mult = pow(1.5, i)
		_create_realm_from_data("Thiên Nhân Đệ %d Suy" % i, "quado_thiennhan_%d" % i, cp, 3e7 * stat_mult, 1.5e7 * stat_mult, 7.5e6 * stat_mult)

func _generate_TamBo_KhongNiet():
	_create_realm_from_data("Không Niết Sơ Kỳ", "tambo_khongniet_1", 1e14, 1e8, 5e7, 2.5e7)
	_create_realm_from_data("Không Niết Trung Kỳ", "tambo_khongniet_2", 4e14, 1.5e8, 7.5e7, 3.8e7)
	_create_realm_from_data("Không Niết Hậu Kỳ", "tambo_khongniet_3", 9e14, 2.2e8, 1.1e8, 5.5e7)

func _generate_TamBo_KhongLinh():
	_create_realm_from_data("Không Linh Sơ Kỳ", "tambo_khonglinh_1", 2e15, 5e8, 2.5e8, 1.2e8)
	_create_realm_from_data("Không Linh Trung Kỳ", "tambo_khonglinh_2", 5e15, 7.5e8, 3.8e8, 1.9e8)
	_create_realm_from_data("Không Linh Hậu Kỳ", "tambo_khonglinh_3", 9e15, 1.1e9, 5.5e8, 2.7e8)

func _generate_TamBo_KhongHuyen():
	_create_realm_from_data("Không Huyền Sơ Kỳ", "tambo_khonghuyen_1", 2e16, 2.5e9, 1.2e9, 6e8)
	_create_realm_from_data("Không Huyền Trung Kỳ", "tambo_khonghuyen_2", 5e16, 3.8e9, 1.9e9, 9.5e8)
	_create_realm_from_data("Không Huyền Hậu Kỳ", "tambo_khonghuyen_3", 9e16, 5.5e9, 2.7e9, 1.3e9)

func _generate_TamBo_KhongKiep():
	_create_realm_from_data("Không Kiếp Sơ Kỳ", "tambo_khongkiep_1", 2e17, 1e10, 5e9, 2.5e9)
	_create_realm_from_data("Không Kiếp Trung Kỳ", "tambo_khongkiep_2", 5e17, 1.5e10, 7.5e9, 3.8e9)
	_create_realm_from_data("Không Kiếp Hậu Kỳ", "tambo_khongkiep_3", 9e17, 2.2e10, 1.1e10, 5.5e9)

func _generate_TamBo_Ton():
	_create_realm_from_data("Kim Tôn", "tambo_kimton", 2e18, 5e10, 2.5e10, 1.2e10)
	_create_realm_from_data("Thiên Tôn", "tambo_thienton", 5e18, 1e11, 5e10, 2.5e10)
	_create_realm_from_data("Dược Thiên Tôn", "tambo_duocthienton", 8e18, 1.5e11, 7.5e10, 3.8e10)
	_create_realm_from_data("Đại Thiên Tôn", "tambo_daithienton", 2e19, 3e11, 1.5e11, 7.5e10)

func _generate_QuaDo_DapThienKieu():
	for i in range(1, 10):
		var cp = 5e19 * pow(3, i)
		var stat_mult = pow(2, i)
		_create_realm_from_data("Đạp Thiên Kiều %d" % i, "quado_dapthienkieu_%d" % i, cp, 1e12 * stat_mult, 5e11 * stat_mult, 2.5e11 * stat_mult)

func _generate_TuBo_DapThien():
	_create_realm_from_data("Đạp Thiên Cảnh", "tubo_dapthien", 1e22, 1e14, 5e13, 2.5e13)

#-------------------------------------------------------------------
# CÁC HÀM TIỆN ÍCH
#-------------------------------------------------------------------

func _save_realm(realm_data: RealmData, file_suffix: String):
	global_index += 1
	var file_path = REALMS_FOLDER_PATH.path_join("realm_%03d_%s.tres" % [global_index, file_suffix])
	ResourceSaver.save(realm_data, file_path)

func _create_realm_from_data(name: String, suffix: String, cp: float, se: int, atk: int, def: int):
	var realm = RealmData.new()
	realm.realmName = name
	realm.requiredCp = cp
	realm.bonusMaxSe = se
	realm.bonusAttack = atk
	realm.bonusDefense = def
	_save_realm(realm, suffix)
