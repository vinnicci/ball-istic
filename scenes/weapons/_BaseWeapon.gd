extends Node2D

#be sure to name root node as Weapon
#however you can name the scene as anything

export (PackedScene) var Projectile
export (float) var heat_per_shot = 1
export (float) var heat_capacity = 20
export (float) var heat_dissipation = 2
var current_heat: float


func get_projectile() -> Area2D:
	$Cooldown.start()
	current_heat += heat_per_shot
	return Projectile.instance()


func _process(_delta: float) -> void:
	if current_heat > heat_capacity:
		$AnimationPlayer.play("overheat")
		$OverheatCooldown.start()


func _on_DissipationCooldown_timeout() -> void:
	if current_heat > 0:
		current_heat -= heat_dissipation


func _on_OverheatCooldown_timeout() -> void:
	$AnimationPlayer.play_backwards("overheat")
