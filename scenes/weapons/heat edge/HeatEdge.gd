extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var normal_proj: PackedScene = preload("res://scenes/weapons/heat edge/HeatEdgeNormalProj.tscn")
var super_proj: PackedScene = preload("res://scenes/weapons/heat edge/HeatEdgeSuperProj.tscn")


func _ready() -> void:
	Projectile = normal_proj


func _process(delta: float) -> void:
	if _is_almost_overheating == true:
		Projectile = super_proj
		self.shoot_cooldown = 0.05
		$Sprite/Anim.playback_speed = 4
		$Sprite/Barrel.modulate = Color(0.95, 0.15, 0.15)
		$Sprite/Tank1.modulate = Color(0.95, 0.15, 0.15)
		$Sprite/Tank2.modulate = Color(0.95, 0.15, 0.15)
	else:
		Projectile = normal_proj
		self.shoot_cooldown = 0.2
		$Sprite/Anim.playback_speed = 1
		$Sprite/Barrel.modulate = Color(1,1,1)
		$Sprite/Tank1.modulate = Color(1,1,1)
		$Sprite/Tank2.modulate = Color(1,1,1)
