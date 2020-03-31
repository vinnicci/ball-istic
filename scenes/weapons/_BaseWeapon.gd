extends Node2D


#be sure to name root node as Weapon
#however you can name the scene as anything
export (PackedScene) var Projectile
export (float) var heat_per_shot: = 10.0
export (float) var heat_capacity: = 50
export (float) var heat_dissipation_per_second: = 10.0
export (float) var heat_cooled_factor: float = 0.7 #heat must be below this threshold to return firing
var current_heat: float
var is_overheating: bool = false


func _ready() -> void:
	if heat_per_shot < 3:
		heat_per_shot = 3
	if heat_dissipation_per_second < 2:
		heat_dissipation_per_second = 2


func get_projectiles() -> Array:
	$Cooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	current_heat += heat_per_shot
	return _instantiate_projectile()


#bundle projectiles
func _instantiate_projectile() -> Array:
	return [Projectile.instance()]


func _process(_delta: float) -> void:
	if current_heat > heat_capacity:
		is_overheating = true
	if is_overheating == true && current_heat < heat_capacity * heat_cooled_factor:
		is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if current_heat > 0:
		current_heat -= heat_dissipation_per_second/2


func _on_Cooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
