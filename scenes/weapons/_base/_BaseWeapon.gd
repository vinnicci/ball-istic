extends Node2D


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1
export (float) var heat_capacity: float = 5
export (float) var heat_dissipation_per_sec: float = 1
export (float, 0, 1.0) var heat_cooled_factor: float = 0.7 #heat must be below this threshold to return firing
export (float) var shoot_cooldown: float = 1.0

var _current_heat: float setget , current_heat
var _is_overheating: bool = false setget , is_overheating

onready var _parent_node: Node = get_parent().get_parent() setget set_parent_node, get_parent_node


func current_heat():
	return _current_heat


func is_overheating():
	return _is_overheating


func set_parent_node(new_parent: Node):
	_parent_node = new_parent


func get_parent_node():
	return _parent_node


func _ready() -> void:
	$ShootCooldown.wait_time = shoot_cooldown


func get_projectiles() -> Array:
	$ShootCooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	$ShootingSound.play()
	_current_heat += heat_per_shot
	return _instantiate_projectile()


func animate_transform(transform_speed: float) -> void:
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
	if visible == true && _parent_node.is_rolling() == true:
		hide()
		modulate = Color(1,1,1,1)


func _instantiate_projectile() -> Array:
	var projectiles = [Projectile.instance()]
	return projectiles


func _process(_delta: float) -> void:
	#some weapons can't rotate 360 deg
#	if is_instance_valid(Globals.player) && parent_node == Globals.player && parent_node.is_in_control == true:
#		look_at(get_global_mouse_position())
	if _current_heat > heat_capacity && _is_overheating == false:
		_current_heat = heat_capacity + (heat_capacity*0.05)
		_is_overheating = true
	elif _is_overheating == true && _current_heat <= heat_capacity * heat_cooled_factor:
		_is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if _current_heat > 0:
		_current_heat -= heat_dissipation_per_sec/4 #<- rate 1sec/4
	elif _current_heat <= 0:
		_current_heat = 0


func _on_Cooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
