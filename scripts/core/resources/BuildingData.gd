# BuildingData.gd
# Khuôn mẫu dữ liệu cho TỪNG CẤP BẬC của một công trình.
class_name BuildingData
extends Resource

@export var level: int = 1
@export var name: String = "Tên Công Trình Cấp %d" % level
@export_multiline var description: String = "Mô tả hiệu quả của công trình ở cấp này."

# Yêu cầu để nâng cấp LÊN cấp này.
@export var upgrade_cost: Dictionary = {"spirit_stones": 100}

# Hiệu quả mà cấp này mang lại.
# Ví dụ: {"spirit_energy_regen": 0.5} (hồi 0.5 linh khí mỗi giây)
# Ví dụ: {"spirit_grass_yield": 1} (sản xuất 1 Linh Thảo mỗi giờ)
@export var effects: Dictionary = {}
