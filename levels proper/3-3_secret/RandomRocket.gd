extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		100: [
			preload("res://scenes/weapons/rocket/Barrage.tscn"),
			preload("res://scenes/weapons/rocket/BarrageEco.tscn"),
			preload("res://scenes/weapons/rocket/Salvo.tscn"),
			preload("res://scenes/weapons/rocket/SalvoEco.tscn")
		]
	}
