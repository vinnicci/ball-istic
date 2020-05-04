extends "res://scenes/global/_base item/_BaseItem.gd"


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1 setget , get_heat_per_shot
export (float) var heat_capacity: float = 5 setget , get_heat_capacity
export (float) var heat_dissipation_per_sec: float = 1 setget , get_heat_dissipation
#heat must be below this threshold to return firing
export (float, 0, 1.0) var heat_cooled_threshold: float = 0 setget , get_heat_cooled_threshold
export (float) var shoot_cooldown: float = 1.0 setget , get_shoot_cooldown
enum FireModes {AUTO, SEMI_AUTO, BURST, CHARGE}
export (FireModes) var fire_mode setget , get_fire_mode

var _current_heat: float setget , current_heat
var _is_overheating: bool = false setget , is_overheating


func get_heat_per_shot():
	return heat_per_shot

func get_heat_capacity():
	return heat_capacity

func get_heat_dissipation():
	return heat_dissipation_per_sec

func get_heat_cooled_threshold():
	return heat_cooled_threshold

func get_shoot_cooldown():
	return shoot_cooldown

func get_fire_mode():
	return fire_mode

func current_heat():
	return _current_heat

func is_overheating():
	return _is_overheating


func _ready() -> void:
	$ShootCooldown.wait_time = shoot_cooldown


func fire() -> Array:
	if $ShootCooldown.is_stopped() == false:
		return []
	$ShootCooldown.start()
	if _is_overheating == true:
		return []
	match fire_mode:
		0: return _fire_auto()
		1: return _fire_semi_auto()
		2: return _fire_burst()
		3: return _fire_charged()
		_: return []


func _fire_auto() -> Array:
	$Muzzle/MuzzleParticles.emitting = true
	$ShootingSound.play()
	_current_heat += heat_per_shot
	return _instantiate_projectile()


func _fire_semi_auto() -> Array:
	return []


func _fire_burst() -> Array:
	return []


func _fire_charged() -> Array:
	return []


func _instantiate_projectile() -> Array:
	var projectiles = [Projectile.instance()]
	return projectiles


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


func _process(_delta: float) -> void:
	if _current_heat > heat_capacity && _is_overheating == false:
		_current_heat = heat_capacity + (heat_capacity*0.05)
		_is_overheating = true
	elif _is_overheating == true && _current_heat <= heat_capacity * heat_cooled_threshold:
		_is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if _current_heat > 0:
		_current_heat -= heat_dissipation_per_sec/4 #<- rate 1sec/4
	elif _current_heat <= 0:
		_current_heat = 0


func _on_ShootCooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false
