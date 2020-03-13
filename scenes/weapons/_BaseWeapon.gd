extends Node2D

#be sure to name root node as Weapon
#however you can name the scene as anything

export (PackedScene) var Projectile
export (int) var heat_per_shot: = 10 #absolute minimum is 3
export (int) var heat_capacity: = 50
export (int) var heat_dissipation_per_second: = 10 #absolute minimum is 2
var current_heat: int


func _ready() -> void:
	if heat_per_shot < 3:
		heat_per_shot = 3
	if heat_dissipation_per_second < 2:
		heat_dissipation_per_second = 2


func get_projectile() -> Array:
	$Cooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
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


func _on_Cooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
