extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		100: [
			preload("res://scenes/weapons/blaster/AutoBlasterReflecting.tscn"),
			preload("res://scenes/weapons/blaster/BurstBlasterReflecting.tscn"),
			preload("res://scenes/weapons/blaster/ChargeBlasterReflecting.tscn")
		],
		50: [
			preload("res://scenes/weapons/heavy blaster/HeavyBlasterReflecting.tscn"),
			preload("res://scenes/weapons/shotgun/PulseShotgun.tscn")
		],
		25: [
			preload("res://scenes/weapons/pincer/Pincer.tscn"),
			preload("res://scenes/weapons/pincer/StunPincer.tscn"),
			preload("res://scenes/weapons/dagger/Dagger.tscn")
		],
		13: [
			preload("res://scenes/weapons/blaster/AutoBlasterHoming.tscn"),
			preload("res://scenes/weapons/blaster/BurstBlasterHoming.tscn"),
			preload("res://scenes/weapons/blaster/ChargeBlasterHoming.tscn"),
			preload("res://scenes/weapons/heavy blaster/HeavyBlasterHoming.tscn")
		]
	}
