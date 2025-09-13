# QuestData.gd
# Khuôn mẫu dữ liệu cho tất cả các nhiệm vụ.
class_name QuestData
extends Resource

@export var questId: String = ""
@export var title: String = "Tên Nhiệm Vụ"
@export_multiline var description: String = "Mô tả cốt truyện của nhiệm vụ."

# Mảng chứa các mục tiêu. Mỗi mục tiêu là một Dictionary.
# Ví dụ: {"type": "kill", "target_id": "enemy_rival_disciple", "quantity": 1}
# Ví dụ: {"type": "craft", "target_id": "item_basic_healing_pill", "quantity": 3}
@export var objectives: Array = []

# Dictionary chứa phần thưởng. Key: "cp", "spirit_stones", hoặc item ID. Value: số lượng.
@export var rewards: Dictionary = {}
