# Resource này chứa tất cả thông tin về một địa điểm trên bản đồ.
extends Resource

# Annotation để Godot biết cách đăng ký class này
class_name LocationData

# ID duy nhất của địa điểm, ví dụ: "hang_nhac_tong"
@export var location_id: String = ""
# Tên sẽ hiển thị trong game, ví dụ: "Hằng Nhạc Tông"
@export var location_name: String = "Địa Điểm Mới"
# Mô tả ngắn về địa điểm
@export var description: String = "Một nơi bí ẩn..."

# Hình nền sẽ được hiển thị khi người chơi ở địa điểm này
@export var background_texture: Texture2D

# Danh sách ID của các NPC có mặt tại đây
@export var npc_ids: Array[String]
# Danh sách ID của các loại kẻ địch có thể gặp tại đây
@export var enemy_ids: Array[String]
