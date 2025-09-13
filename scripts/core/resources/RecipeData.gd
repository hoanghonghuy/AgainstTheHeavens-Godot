# RecipeData.gd
# Khuôn mẫu dữ liệu cho tất cả các công thức chế tạo.
class_name RecipeData
extends Resource

enum CraftingType {
	ALCHEMY, # Luyện Đan
	FORGING, # Luyện Khí / Chế Tạo
	FORMATION # Chế Tác Trận Đồ
}

@export var recipeId: String = ""
@export var outputItemId: String = "" # ID của vật phẩm thành phẩm
@export var outputQuantity: int = 1   # Số lượng thành phẩm
@export var craftingType: CraftingType = CraftingType.ALCHEMY

# Dùng Dictionary để lưu nguyên liệu: Key là Item ID, Value là số lượng yêu cầu.
@export var requiredIngredients: Dictionary = {}
