extends Node2D

#be sure to name root node as Weapon
#however you can name the scene as anything

export (PackedScene) var Projectile
export (float) var heat_per_shot = 2.5 #absolute minimum is 2.5
export (float) var heat_capacity = 50
export (float) var heat_dissipation_per_second = 5
var current_heat: float


func get_projectile() -> Array:
	$Cooldown.start()
	current_heat += heat_per_shot
	return _instantiate_projectile()


#overridable function to bundle projectiles
#useful especially for shotgun type weapons
func _instantiate_projectile() -> Array:
	return []


func _process(_delta: float) -> void:
	if current_heat > heat_capacity:
		$OverheatCooldown.start()


func _on_DissipationCooldown_timeout() -> void:
	if current_heat > 0:
		current_heat -= heat_dissipation_per_second/2
