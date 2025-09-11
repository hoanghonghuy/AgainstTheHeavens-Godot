# ItemData.gd
# Khuôn mẫu dữ liệu cho tất cả các vật phẩm trong game.
# Kế thừa từ Resource để có thể tạo và chỉnh sửa file .tres trong Editor.
class_name ItemData
extends Resource

#== Thông tin cơ bản ==
@export var id: String = "" # ID độc nhất, ví dụ: "item_truc_co_dan"
@export var itemName: String = "Tên Vật Phẩm"
@export_multiline var description: String = "Mô tả chi tiết về vật phẩm."

#== Phân loại & Hình ảnh ==
# Sử dụng Enum để giới hạn các lựa chọn, tránh gõ sai.
enum ItemType {
	CONSUMABLE,  # Đan dược, linh quả (tiêu hao)
	WEAPON,      # Vũ khí
	ARMOR,       # Giáp trụ
	ACCESSORY,   # Phụ kiện
	MATERIAL,    # Nguyên liệu chế tạo, luyện đan
	QUEST_ITEM   # Vật phẩm nhiệm vụ
}
@export var itemType: ItemType = ItemType.MATERIAL
@export var icon: Texture2D # Biến để kéo thả ảnh icon vào

#== Thuộc tính & Quy tắc ==
@export var isStackable: bool = true # Có thể xếp chồng trong túi đồ không?
@export var isUsable: bool = false   # Có thể sử dụng trực tiếp không?
@export var isEquippable: bool = false # Có thể trang bị không?

#== Hiệu ứng (nếu có) ==
# Dictionary để lưu các hiệu ứng, ví dụ: {"healthPoints": 50, "attackPower": 10}
# Sẽ được xử lý khi người chơi sử dụng hoặc trang bị vật phẩm.
@export var effects: Dictionary = {}
