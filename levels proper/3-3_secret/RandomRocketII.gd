extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		100: [
			preload("res://scenes/weapons/rocket/BarrageEcoGuided.tscn"),
			preload("res://scenes/weapons/rocket/BarrageGuided.tscn"),
			preload("res://scenes/weapons/rocket/SalvoEcoGuided.tscn"),
			preload("res://scenes/weapons/rocket/SalvoGuided.tscn")
		],
		25: [
			preload("res://scenes/weapons/rocket/BarrageEcoHoming.tscn"),
			preload("res://scenes/weapons/rocket/BarrageHoming.tscn"),
			preload("res://scenes/weapons/rocket/SalvoEcoHoming.tscn"),
			preload("res://scenes/weapons/rocket/SalvoHoming.tscn")
		]
	}
