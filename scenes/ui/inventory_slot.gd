# inventory_slot.gd 
extends PanelContainer

@onready var item_icon: TextureRect = %ItemIcon
@onready var quantity_label: Label = %QuantityLabel

var item_data: ItemData

func display_item(data: ItemData, quantity: int):
	item_data = data
	
	# KIỂM TRA MỚI: Chỉ gán texture nếu nó thực sự tồn tại (khác null)
	if item_data.icon != null:
		item_icon.texture = item_data.icon
	else:
		# Nếu không có icon, ta sẽ không làm gì cả (để ô icon trống)
		# và in ra một cảnh báo để chúng ta biết.
		item_icon.texture = null
		print("Cảnh báo: Vật phẩm '%s' (ID: %s) không có icon!" % [item_data.itemName, item_data.id])

	# Phần code hiển thị số lượng giữ nguyên
	quantity_label.text = "x%d" % quantity
	quantity_label.visible = item_data.isStackable and quantity > 1
