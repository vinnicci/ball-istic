extends "res://scenes/weapons/_base/_BaseBotProjectile.gd"


func init_travel(pos: Vector2, dir: float) -> void:
	.init_travel(pos, dir)
	$Timers/Lifetime.paused = true
