# CultivationMethodData.gd
# Khuôn mẫu dữ liệu cho tất cả các công pháp tu luyện trong game.
class_name CultivationMethodData
extends Resource

#== Thông tin cơ bản ==
@export var id: String = "" # ID độc nhất, ví dụ: "cm_basic_qi_gathering"
@export var methodName: String = "Tên Công Pháp"
@export_multiline var description: String = "Mô tả chi tiết về công pháp."

#== Phân loại & Yêu cầu ==
enum MethodRank {
	COMMON,      # Phàm Phẩm
	SPIRIT,      # Linh Phẩm
	EARTH,       # Địa Phẩm
	HEAVEN,      # Thiên Phẩm
	DIVINE       # Thần Phẩm
}
@export var rank: MethodRank = MethodRank.COMMON

# Yêu cầu về cảnh giới để có thể tu luyện (sẽ kiểm tra sau này)
@export var realmRequirement: String = "Luyện Khí Kỳ Tầng Một"
# Yêu cầu về linh căn (để trống nếu không có)
@export var spiritRootRequirement: String = ""

#== Hiệu ứng Tu luyện ==
# Công pháp này mang lại hiệu quả gì khi người chơi tu luyện nó.
# Ví dụ: Tăng điểm tu vi mỗi giây, tăng giới hạn linh khí...
# Key: Tên chỉ số (ví dụ: "cultivationPoints_per_second"), Value: giá trị tăng thêm.
@export var passiveEffects: Dictionary = {}

#== Hiệu ứng Kích hoạt (nếu có) ==
# Một số công pháp có thể đi kèm một kỹ năng chủ động.
# Chúng ta sẽ liên kết tới một SkillData sau này.
# @export var activeSkill: SkillData
