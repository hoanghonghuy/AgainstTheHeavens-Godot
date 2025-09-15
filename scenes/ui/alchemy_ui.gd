# alchemy_ui.gd
extends Control

# Tín hiệu báo cho MainScene biết người chơi muốn đóng giao diện này
signal closed

#== THAM CHIẾU ĐẾN CÁC NODE GIAO DIỆN ==
@onready var recipe_list_container: VBoxContainer = %RecipeListContainer
@onready var selected_recipe_name_label: Label = %SelectedRecipeNameLabel
@onready var ingredients_container: VBoxContainer = %IngredientsContainer
@onready var output_slot: PanelContainer = %OutputSlot
@onready var craft_button: Button = %CraftButton
@onready var player_inventory_grid: GridContainer = %PlayerInventoryGrid
@onready var close_button: Button = %CloseButton

var selected_recipe: RecipeData = null

func _ready() -> void:
	# close_button.pressed.connect(_on_close_button_pressed)
	# craft_button.pressed.connect(_on_craft_button_pressed)
	self.hide()

func open_panel():
	self.show()
	_update_all_displays()

func _on_close_button_pressed():
	self.hide()
	closed.emit()

func _update_all_displays():
	_populate_recipe_list()
	_populate_player_inventory()
	_display_selected_recipe_details()

func _populate_recipe_list():
	for child in recipe_list_container.get_children():
		child.queue_free()

	# --- BẮT ĐẦU VÙNG DEBUG ---
	print("==========================================")
	print("Bắt đầu cập nhật danh sách công thức...")
	print("Công thức đã biết trong PlayerState: ", PlayerState.learnedRecipes)
	print("------------------------------------------")
	# --- KẾT THÚC VÙNG DEBUG ---
	
	for recipe_id in PlayerState.learnedRecipes:
		# --- DEBUG BÊN TRONG VÒNG LẶP ---
		print("Đang xử lý công thức ID: '", recipe_id, "'")
		var recipe_data: RecipeData = Database.recipes.get(recipe_id)
		
		if recipe_data:
			print(">> Đã tìm thấy dữ liệu cho '", recipe_id, "' trong Database.")
			var output_item_data: ItemData = Database.items.get(recipe_data.outputItemId)
			if output_item_data:
				print(">> >> Thành phẩm: '", output_item_data.itemName, "'. Đang tạo nút...")
				var recipe_button = Button.new()
				recipe_button.text = output_item_data.itemName
				recipe_button.pressed.connect(_on_recipe_selected.bind(recipe_data))
				recipe_list_container.add_child(recipe_button)
			else:
				print(">> >> LỖI: Không tìm thấy dữ liệu THÀNH PHẨM với ID: '", recipe_data.outputItemId, "'")
		else:
			print(">> LỖI: Không tìm thấy dữ liệu CÔNG THỨC với ID: '", recipe_id, "' trong Database!")
			
	print("==========================================")

func _on_recipe_selected(recipe_data: RecipeData):
	selected_recipe = recipe_data
	_display_selected_recipe_details()

func _display_selected_recipe_details():
	if selected_recipe == null:
		selected_recipe_name_label.text = "Chọn một công thức"
		craft_button.disabled = true
		output_slot.hide()
		for child in ingredients_container.get_children(): child.queue_free()
		return

	var output_item_data = Database.items.get(selected_recipe.outputItemId)
	selected_recipe_name_label.text = output_item_data.itemName
	
	output_slot.display_item(output_item_data, selected_recipe.outputQuantity)
	output_slot.show()
	
	for child in ingredients_container.get_children(): child.queue_free()
	var can_craft = true
	for item_id in selected_recipe.requiredIngredients:
		var required_qty = selected_recipe.requiredIngredients[item_id]
		var player_qty = PlayerState.inventory.get(item_id, 0)
		var ingredient_data = Database.items.get(item_id)
		
		var label = Label.new()
		label.text = "%s: %d / %d" % [ingredient_data.itemName, player_qty, required_qty]
		if player_qty < required_qty:
			label.add_theme_color_override("font_color", Color.RED)
			can_craft = false
		
		ingredients_container.add_child(label)
		
	craft_button.disabled = not can_craft

func _populate_player_inventory():
	for child in player_inventory_grid.get_children():
		child.queue_free()
		
	for item_id in PlayerState.inventory:
		var item_data = Database.items.get(item_id)
		if item_data and item_data.itemType == ItemData.ItemType.MATERIAL:
			var slot = preload("res://scenes/ui/inventory_slot.tscn").instantiate()
			player_inventory_grid.add_child(slot)
			slot.display_item(item_data, PlayerState.inventory[item_id])

func _on_craft_button_pressed():
	if selected_recipe == null or craft_button.disabled:
		return
		
	for item_id in selected_recipe.requiredIngredients:
		var required_qty = selected_recipe.requiredIngredients[item_id]
		PlayerState.inventory[item_id] -= required_qty
		if PlayerState.inventory[item_id] <= 0:
			PlayerState.inventory.erase(item_id)
			
	var output_id = selected_recipe.outputItemId
	var output_qty = selected_recipe.outputQuantity
	PlayerState.inventory[output_id] = PlayerState.inventory.get(output_id, 0) + output_qty
	
	# Thông báo cho toàn bộ game biết rằng một vật phẩm đã được chế tạo
	PlayerState.item_crafted.emit(output_id, output_qty)
	
	print("Luyện chế thành công %s!" % Database.items[output_id].itemName)
	
	_update_all_displays()
