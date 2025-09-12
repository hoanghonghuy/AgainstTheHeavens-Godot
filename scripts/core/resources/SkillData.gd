# SkillData.gd
# Khuôn mẫu dữ liệu cho tất cả các kỹ năng (thần thông) trong game.
class_name SkillData
extends Resource

@export var skillId: String = "" # ID độc nhất, ví dụ: "skill_fireball"
@export var skillName: String = "Tên Kỹ Năng"
@export_multiline var description: String = "Mô tả chi tiết về hiệu ứng của kỹ năng."

@export_group("Yêu Cầu & Tiêu Hao")
@export var spiritEnergyCost: int = 10 # Lượng Linh Khí tiêu hao để sử dụng

@export_group("Hiệu Ứng Chính")
# Loại mục tiêu: Tấn công kẻ địch hay hỗ trợ bản thân?
enum TargetType {
	ENEMY,
	SELF
}
@export var targetType: TargetType = TargetType.ENEMY

# Sát thương được tính bằng (công kích của người chơi * damageMultiplier)
@export var damageMultiplier: float = 1.5 

# Có thể thêm các hiệu ứng khác sau này, ví dụ:
# @export var statusEffect: String = "burning" # Gây hiệu ứng bỏng
# @export var duration: int = 3 # Hiệu ứng kéo dài 3 lượt
