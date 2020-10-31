extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		100: [
			preload("res://scenes/weapons/fortress/Fortress.tscn"),
			preload("res://scenes/weapons/cannon/PulseCannon.tscn"),
			preload("res://scenes/weapons/paladin's hammer/PaladinHammer.tscn")
		],
		50: [
			preload("res://scenes/weapons/blaster/AutoBlasterHoming.tscn"),
			preload("res://scenes/weapons/blaster/BurstBlasterHoming.tscn"),
			preload("res://scenes/weapons/blaster/ChargeBlasterHoming.tscn")
		]
	}
