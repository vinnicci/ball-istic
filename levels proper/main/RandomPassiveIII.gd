extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		0: [
			preload("res://scenes/passives/charge cooldown/ChargeCooldownIII.tscn"),
			preload("res://scenes/passives/charge damage rate/ChargeDmgRateIII.tscn"),
			preload("res://scenes/passives/charge force/ChargeForceIII.tscn"),
			preload("res://scenes/passives/health capacity/HealthCapacityIII.tscn"),
			preload("res://scenes/passives/resistance/ResistanceIII.tscn"),
			preload("res://scenes/passives/shield capacity/ShieldCapacityIII.tscn"),
			preload("res://scenes/passives/speed/SpeedIII.tscn"),
			preload("res://scenes/passives/transform speed/TransformSpeedIII.tscn"),
			preload("res://scenes/passives/weapon damage rate/WeapDmgRateIII.tscn"),
			preload("res://scenes/passives/weapon heat capacity/WeaponHeatCapacityIII.tscn")
		],
	}
