extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var left_proj: PackedScene = preload("res://scenes/weapons/rbarrage/RBarrageProj1.tscn")
var right_proj: PackedScene = preload("res://scenes/weapons/rbarrage/RBarrageProj2.tscn")


func _ready() -> void:
	$Muzzle.position = $MuzzlePos/P0.position


func _fire_burst() -> void:
	if _current_burst_count % 2 == 0:
		Projectile = left_proj
	else:
		Projectile = right_proj
	var muzzle_pos = get_node("MuzzlePos/P" + _current_burst_count as String)
	$Muzzle.transform = muzzle_pos.transform
	._fire_burst()
