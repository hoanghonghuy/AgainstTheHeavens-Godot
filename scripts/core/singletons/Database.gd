# Database.gd
extends Node

var game_data_resource: GameData
var realms: Array[RealmData]

func _ready() -> void:
	game_data_resource = load("res://data/game_data.tres")

	if game_data_resource:
		realms = game_data_resource.realms
		print("Cơ sở dữ liệu game đã được TÁI SINH thành công!")
	else:
		print("LỖI NGHIÊM TRỌNG: KHÔNG THỂ TẢI FILE 'res://data/game_data.tres'!")
