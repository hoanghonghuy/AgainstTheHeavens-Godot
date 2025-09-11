# EnemyData.gd
# Khuôn mẫu dữ liệu cho tất cả các kẻ địch trong game.
class_name EnemyData
extends Resource

@export var enemyName: String = "Tên Kẻ Địch"
# Hình ảnh của kẻ địch sẽ hiển thị trong trận đấu
@export var sprite: Texture2D 

@export_group("Chỉ Số Cơ Bản")
@export var maxHp: int = 50
@export var attackPower: int = 10
@export var defense: int = 2
@export var speed: int = 5 # Tốc độ quyết định lượt đi

@export_group("Phần Thưởng Khi Bị Đánh Bại")
@export var cpReward: float = 10.0 # Lượng Tu Vi nhận được
# Bảng vật phẩm rơi ra. Key: ID vật phẩm, Value: tỷ lệ rơi (0.0 -> 1.0)
@export var lootTable: Dictionary = {}
