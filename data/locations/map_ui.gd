# map_ui.gd
extends Control

signal travel_requested(location_id: String)
signal closed

@onready var location_list: VBoxContainer = %LocationList
@onready var location_name_label: Label = %LocationNameLabel
@onready var location_description_label: Label = %LocationDescriptionLabel
@onready var travel_button: Button = %TravelButton
@onready var close_button: Button = %CloseButton

var _selected_location: LocationData = null

func _ready() -> void:
	travel_button.pressed.connect(_on_travel_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	self.hide()

func open_panel():
	self.show()
	_populate_location_list()
	
	if _selected_location == null or _selected_location.location_id == PlayerState.current_location_id:
		_clear_location_details()

func _populate_location_list():
	for child in location_list.get_children():
		child.queue_free()
	
	var all_locations = Database.locations
	
	for location_id in all_locations:
		var location_data: LocationData = all_locations[location_id]
		var loc_button = Button.new()
		loc_button.text = location_data.location_name
		
		if location_id == PlayerState.current_location_id:
			loc_button.disabled = true
		
		loc_button.pressed.connect(_display_location_details.bind(location_data))
		location_list.add_child(loc_button)

func _display_location_details(location_data: LocationData):
	_selected_location = location_data
	location_name_label.text = location_data.location_name
	location_description_label.text = location_data.description
	travel_button.disabled = false

func _clear_location_details():
	_selected_location = null
	location_name_label.text = "Chọn một địa điểm"
	location_description_label.text = ""
	travel_button.disabled = true

func _on_travel_button_pressed():
	if _selected_location:
		travel_requested.emit(_selected_location.location_id)

func _on_close_button_pressed():
	closed.emit()
