extends Node2D


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1
export (float) var heat_capacity: float = 5
export (float) var heat_dissipation_per_sec: float = 1
export (float, 0, 1.0) var heat_cooled_factor: float = 0.7 #heat must be below this threshold to return firing
export (float) var shoot_cooldown: float = 1.0

var current_heat: float
var is_overheating: bool = false
var class_bot = preload("res://scenes/bots/_base/_BaseBot.gd")
var parent_init: bool = false

onready var parent_node: Node = get_parent().get_parent()


func _ready() -> void:
	$ShootCooldown.wait_time = shoot_cooldown


func get_projectiles() -> Array:
	$ShootCooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	$ShootingSound.play()
	current_heat += heat_per_shot
	return _instantiate_projectile()


func _animate_transform(transform_speed: float) -> void:
	if visible == true:
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0),
			transform_speed/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif visible == false:
		modulate = Color(1,1,1,0)
		show()
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1),
			transform_speed/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$WeaponTween.start()


func _on_WeaponTween_tween_all_completed() -> void:
	if visible == true && parent_node.roll_mode == true:
		hide()
		modulate = Color(1,1,1,1)


func _instantiate_projectile() -> Array:
	var projectiles = [Projectile.instance()]
	return projectiles


func _process(_delta: float) -> void:
	#find a way to fix this
	if parent_node is class_bot == false && parent_init == false:
		parent_node.get_node("Items").remove_child(self)
		parent_node = Globals.player.get_ref()
		parent_node.get_node("Weapons").add_child(self)
		parent_init = true
	if current_heat > heat_capacity && is_overheating == false:
		current_heat = heat_capacity + (heat_capacity*0.05)
		is_overheating = true
	elif is_overheating == true && current_heat <= heat_capacity * heat_cooled_factor:
		is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if current_heat > 0:
		current_heat -= heat_dissipation_per_sec/4 #<- rate 1sec/4
	elif current_heat <= 0:
		current_heat = 0


func _on_Cooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
