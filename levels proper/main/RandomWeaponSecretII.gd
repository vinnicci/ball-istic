extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		100: [
			preload("res://scenes/weapons/scattershot/Scattershot.tscn"),
			preload("res://scenes/weapons/scattershot/Sweeper.tscn")
		],
		70: [
			preload("res://scenes/weapons/grenade ballista/GrenadeBallista.tscn"),
			preload("res://scenes/weapons/mine launcher/MineLauncher.tscn"),
			preload("res://scenes/weapons/cyclone/Cyclone.tscn")
		],
		50: [
			preload("res://scenes/weapons/shotgun/PulseShotgun.tscn"),
			preload("res://scenes/weapons/sniper/PulseSniper.tscn"),
			preload("res://scenes/weapons/mine launcher/PulseMineLauncher.tscn"),
			preload("res://scenes/weapons/scattershot/ScattershotReflecting.tscn"),
			preload("res://scenes/weapons/scattershot/SweeperReflecting.tscn")
		],
		10: [
			preload("res://scenes/weapons/scattershot/ScattershotHoming.tscn"),
			preload("res://scenes/weapons/scattershot/SweeperHoming.tscn")
		]
	}
