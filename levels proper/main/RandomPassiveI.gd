extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		0: [
			preload("res://scenes/passives/charge cooldown/ChargeCooldownI.tscn"),
			preload("res://scenes/passives/charge damage rate/ChargeDmgRateI.tscn"),
			preload("res://scenes/passives/charge force/ChargeForceI.tscn"),
			preload("res://scenes/passives/health capacity/HealthCapacityI.tscn"),
			preload("res://scenes/passives/resistance/ResistanceI.tscn"),
			preload("res://scenes/passives/shield capacity/ShieldCapacityI.tscn"),
			preload("res://scenes/passives/speed/SpeedI.tscn"),
			preload("res://scenes/passives/transform speed/TransformSpeedI.tscn"),
			preload("res://scenes/passives/weapon damage rate/WeapDmgRateI.tscn"),
			preload("res://scenes/passives/weapon heat capacity/WeaponHeatCapacityI.tscn")
		],
	}
