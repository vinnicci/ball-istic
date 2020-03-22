extends Node2D

#be sure to name root node as Weapon
#however you can name the scene as anything

export (PackedScene) var Projectile
export (float) var heat_per_shot: = 10.0
export (float) var heat_capacity: = 50
export (float) var heat_dissipation_per_second: = 10.0
const OVERHEAT_STOPPED_FACTOR: float = 0.5 #heat must be below 50% to return firing
var current_heat: float
var is_overheating: bool = false


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
		is_overheating = true
	if is_overheating == true && current_heat < heat_capacity*OVERHEAT_STOPPED_FACTOR:
		is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if current_heat > 0:
		current_heat -= heat_dissipation_per_second/2


func _on_Cooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
