extends "res://scenes/global/items/random/RandomItem.gd"


func _ready() -> void:
	loot_table = {
		0: [
			preload("res://scenes/passives/charge cooldown/ChargeCooldownII.tscn"),
			preload("res://scenes/passives/charge damage rate/ChargeDmgRateII.tscn"),
			preload("res://scenes/passives/charge force/ChargeForceII.tscn"),
			preload("res://scenes/passives/health capacity/HealthCapacityII.tscn"),
			preload("res://scenes/passives/resistance/ResistanceII.tscn"),
			preload("res://scenes/passives/shield capacity/ShieldCapacityII.tscn"),
			preload("res://scenes/passives/speed/SpeedII.tscn"),
			preload("res://scenes/passives/transform speed/TransformSpeedII.tscn"),
			preload("res://scenes/passives/weapon damage rate/WeapDmgRateII.tscn"),
			preload("res://scenes/passives/weapon heat capacity/WeaponHeatCapacityII.tscn")
		],
	}
