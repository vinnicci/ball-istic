extends Node2D


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1
export (float) var heat_capacity: float = 5
export (float) var heat_dissipation_per_sec: float = 1
export (float, 0.01, 1.0) var heat_cooled_factor: float = 0.7 #heat must be below this threshold to return firing
export (float) var shoot_cooldown: float = 1.0


var current_heat: float
var transform_speed: float
var is_overheating: bool = false

onready var parent_node: = get_parent().get_parent()


func _ready() -> void:
	$ShootCooldown.wait_time = shoot_cooldown


func get_projectiles() -> Array:
	$ShootCooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	$ShootingSound.play()
	current_heat += heat_per_shot
	return _instantiate_projectile()


#bundle projectiles
func _instantiate_projectile() -> Array:
	var projectiles = [Projectile.instance()]
	return projectiles


func _process(_delta: float) -> void:
	if current_heat > heat_capacity:
		is_overheating = true
	if is_overheating == true && current_heat < heat_capacity * heat_cooled_factor:
		is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if current_heat > 0:
		current_heat -= heat_dissipation_per_sec/2
	elif current_heat < 0:
		current_heat = 0


func _on_Cooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
