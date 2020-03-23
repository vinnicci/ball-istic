extends RigidBody2D

#make sure to import body texture with repeating enabled

export (float, 25.0, 100.0) var bot_radius: = 32.0
export (float) var shield_capacity: = 20
export (float) var health_capacity: = 20
export (int, 0, 3000) var roll_speed: = 1200
export (float) var shield_recovery_per_second: = 1.0
export (float, 0.1, 0.8) var transform_speed: = 0.6
export (float, 0.5, 3.0) var charge_cooldown: = 2.5
export (float, 0, 1.0) var knockback_resist: = 0.1
export (float, 0, 1.0) var charge_force_factor: = 0.5
export (bool) var is_destructible: = true
export (bool) var is_hostile: = true

const AVERAGE_BOT_RADIUS: float = 32.0
const BARS_OFFSET: int = 15
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.65
const NO_EFFECT_VELOCITY_FACTOR: float = 0.6
const OUTLINE_SIZE: float = 4.0
const ROLLING_EFFECT_FACTOR: float = 0.01
const ROLL_MODE_DAMP: int = 2
const SHOOT_MODE_DAMP: int = 5
const CHARGE_DAMAGE_FACTOR: float = 0.03
const POLY_SIDES = 24
var _legs_position: Dictionary = {} #private vars but accessible by globals
var _current_shield: float
var _current_health: float
var _current_roll_speed: int
var _current_shield_recovery: float
var _current_transform_speed: float
var _current_charge_cooldown: float
var _current_knockback_resist: float
var _current_charge_force_factor: float
var velocity: Vector2 #public vars
var is_alive: bool = true
var is_charging: bool = false
var is_transforming: bool = false
var is_in_control: bool = true
signal shooting

onready var roll_mode: bool = false
onready var body_outline = $Body/Outline
onready var body_texture = $Body/Texture
onready var body_charge_effect = $Body/ChargeEffect
onready var body_weapon_hatch = $Body/WeaponHatch
onready var bar_shield = $Bars/Shield
onready var bar_health = $Bars/Health
onready var timer_charge_cooldown = $Timers/ChargeCooldown


func _ready() -> void:
	#never changing stuff
	_set_up_default_vars()
	
	#might change on the course of the game
	update_vars()


func _set_up_default_vars() -> void:
	#bot properties
	$CollisionShape.shape.radius = bot_radius
	linear_damp = SHOOT_MODE_DAMP
	
	if is_destructible == false:
		$Bars.hide()
	
	#bot's body set up
	body_texture.scale = Vector2(bot_radius/AVERAGE_BOT_RADIUS, bot_radius/AVERAGE_BOT_RADIUS)
	body_texture.position = Vector2(-bot_radius, -bot_radius)
	bar_shield.rect_position.y += bot_radius + BARS_OFFSET
	bar_health.rect_position.y += bar_shield.rect_position.y + BARS_OFFSET
	var circle_points = _plot_circle_points(bot_radius)
	body_charge_effect.polygon = circle_points
	body_charge_effect.position = Vector2(-bot_radius, -bot_radius)
	body_charge_effect.offset = Vector2(bot_radius, bot_radius)
	var outline = bot_radius + OUTLINE_SIZE
	body_outline.polygon = _plot_circle_points(outline)
	body_outline.position = Vector2(-outline, -outline)
	body_outline.offset = Vector2(outline, outline)
	
	#other set ups
	_set_up_legs([circle_points[4], circle_points[12], circle_points[20]])
	_set_up_hatch([circle_points[0], circle_points[1], circle_points[2], circle_points[10],
		circle_points[11], circle_points[12], circle_points[13], circle_points[14],
		circle_points[22], circle_points[23]])


func _set_up_legs(circle_points) -> void:
	var leg_sprite = $Legs/Sprite
	var leg1 = $Legs/Leg1
	var leg2 = $Legs/Leg2
	var leg3 = $Legs/Leg3
	var deg = 360.0/POLY_SIDES as float
	for i in circle_points.size():
		var leg = leg_sprite.duplicate(DUPLICATE_USE_INSTANCING)
		match i:
			0:
				leg1.add_child(leg)
				leg1.position = circle_points[0]
				_legs_position[leg1] = circle_points[0]
				leg1.rotation = deg2rad(4*deg) #<-- circle degrees * index from circle_points[index]
			1:
				leg2.add_child(leg)
				leg2.position = circle_points[1]
				_legs_position[leg2] = circle_points[1]
				leg2.rotation = deg2rad(12*deg)
			2:
				leg3.add_child(leg)
				leg3.position = circle_points[2]
				_legs_position[leg3] = circle_points[2]
				leg3.rotation = deg2rad(20*deg)
	leg_sprite.hide()


func _set_up_hatch(circle_points: Array) -> void:
	body_weapon_hatch.polygon = circle_points


func _plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(POLY_SIDES):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*(360.0/POLY_SIDES))))
	return circle_points


func update_vars() -> void:
	_current_shield = shield_capacity
	_current_health = health_capacity
	_current_roll_speed = roll_speed
	_current_shield_recovery = shield_recovery_per_second
	_current_transform_speed = transform_speed
	_current_charge_cooldown = charge_cooldown
	_current_knockback_resist = knockback_resist
	_current_charge_force_factor = charge_force_factor
	bar_shield.max_value = shield_capacity
	bar_shield.value = _current_shield
	bar_health.max_value = health_capacity
	bar_health.value = _current_health
	timer_charge_cooldown.wait_time = _current_charge_cooldown


func _process(delta: float) -> void:
	$Bars.global_rotation = 0
	
	#everything charge roll related
	#graphical feedback/effects
	_apply_charging_effects()
	
	#rolling ball graphical effect
	_apply_rolling_effects()
	
	#high speed, transforming, and dying means losing control
	#makes charge roll an attack commitment
	_check_if_in_control()
	
	#velocity calculations
	if is_in_control == true:
		_control(delta)


#60 fps cap
func _physics_process(delta: float) -> void:
	pass


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	_apply_force()


func _control(delta) -> void:
	if has_node("AI") == true:
		$AI._control(delta)


func _apply_force() -> void:
	if roll_mode == true:
		#some ai velocities are already normalized
		if velocity.is_normalized() == false:
			velocity = velocity.normalized() * _current_roll_speed
		else:
			velocity *= _current_roll_speed
	applied_force = velocity


func _apply_charging_effects() -> void:
	var hostile = Color(1, 0.13, 0.13) #red
	var non_hostile = Color(0.4, 1, 0.4) #green
	if linear_velocity.length() <= _current_roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		#outline for hostiles becomes red
		if is_hostile == true:
			body_outline.color = lerp(body_outline.color, hostile, 0.8)
		#outline for non-hostiles becomes green
		elif is_hostile == false:
			body_outline.color = lerp(body_outline.color, non_hostile, 0.8)
		body_charge_effect.color.a = lerp(body_charge_effect.color.a, 0, 0.8)
		body_weapon_hatch.color = body_outline.color
		is_charging = false
	elif linear_velocity.length() > _current_roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR:
		body_outline.color = Color(1, 0.2, 0.8)
		body_charge_effect.color.a = 255
		is_charging = true


func _apply_rolling_effects() -> void:
	if roll_mode == false:
		body_texture.texture_offset = lerp(body_texture.texture_offset, Vector2(0,0), 0.5)
		return
	if roll_mode == true:
		body_texture.texture_offset -= (linear_velocity.rotated(-rotation)/_current_roll_speed) * (_current_roll_speed * ROLLING_EFFECT_FACTOR)


func _check_if_in_control() -> void:
	if is_alive == true && is_charging == false && is_transforming == false:
		is_in_control = true
	else:
		is_in_control = false


func switch_mode() -> void:
	roll_mode = !roll_mode
	_animate_legs()
	_animate_weapon_hatch()
	if roll_mode == true:
		linear_damp = ROLL_MODE_DAMP
		mode = RigidBody2D.MODE_RIGID
	elif roll_mode == false:
		linear_damp = SHOOT_MODE_DAMP
		mode = RigidBody2D.MODE_CHARACTER


func _animate_legs() -> void:
	is_transforming = true
	var leg_tween = $Legs/LegTween
	if roll_mode == true:
		for leg in _legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
				_current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()
	elif roll_mode == false:
		for leg in _legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', Vector2(0,0), _legs_position[leg],
				_current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()


func _on_LegTween_tween_all_completed() -> void:
	is_transforming = false


func _animate_weapon_hatch() -> void:
	is_transforming = true
	var weapon_hatch_tween = body_weapon_hatch.get_node("WeaponHatchTween")
	var weapon_anim: AnimationPlayer
	if has_node("Weapon"):
		weapon_anim = $Weapon/AnimationPlayer
	if roll_mode == true:
		if has_node("Weapon"):
			$Weapon.global_rotation = body_weapon_hatch.global_rotation
			weapon_anim.play("change_mode")
		weapon_hatch_tween.interpolate_property(body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
			_current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif roll_mode == false:
		if has_node("Weapon"):
			body_weapon_hatch.global_rotation = $Weapon.global_rotation
			$Weapon.show()
			weapon_anim.play_backwards("change_mode")
		body_weapon_hatch.show()
		weapon_hatch_tween.interpolate_property(body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
			_current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	weapon_hatch_tween.start()


func _on_WeaponHatchTween_tween_all_completed() -> void:
	if roll_mode == true:
		if has_node("Weapon"):
			$Weapon.hide()
		body_weapon_hatch.hide()
	is_transforming = false


func shoot_weapon() -> void:
	if is_in_control == false || $Weapon/Cooldown.is_stopped() == false || $Weapon.is_overheating == true || roll_mode == true:
		return
	emit_signal("shooting", $Weapon.get_projectile(),
		$Weapon/Muzzle.global_position, $Weapon/Muzzle.global_rotation, is_hostile)


func charge_attack(charge_direction) -> void:
	if is_in_control == false || timer_charge_cooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(Vector2(_current_roll_speed,0).rotated(charge_direction) * _current_charge_force_factor)
	timer_charge_cooldown.start()


func take_damage(damage, knockback) -> void:
	apply_central_impulse(knockback - (knockback*_current_knockback_resist))
	if is_destructible == false:
		return
	if _current_shield - damage >= 0:
		_current_shield -= damage
	elif _current_shield - damage < 0:
		_current_health += _current_shield - damage
		_current_shield = 0
	bar_shield.value = _current_shield
	bar_health.value = _current_health
	if _current_health <= 0:
		_explode()


func _explode() -> void:
	is_alive = false
	if has_node("PlayerBars") == true:
		$PlayerBars.hide()
	$Legs.modulate = Color(0.180392, 0.180392, 0.180392)
	$Body.modulate = Color(0.180392, 0.180392, 0.180392)
	$Bars.hide()
	$Timers/ExplodeDelay.start()


func _on_ExplodeDelay_timeout() -> void:
	if has_node("Weapon"):
		$Weapon.hide()
	$Legs.hide()
	$Body.hide()
	$Bars.hide()
	$CollisionShape.disabled = true
	
	#explosion graphical effect here
	$ExplosionParticles.emitting = true
	$Timers/ExplodeTimer.start()


func _on_ExplodeTimer_timeout() -> void:
	queue_free()


func _on_Bot_body_entered(body: Node) -> void:
	if is_charging == false:
		return
	var damage = _current_roll_speed * CHARGE_DAMAGE_FACTOR
	if body.get_parent().name == "Bots" && is_hostile == body.is_hostile:
		return
	elif body.get_parent().name == "Bots" && is_hostile != body.is_hostile:
		body.take_damage(damage * _current_charge_force_factor, Vector2(0,0))
	else:
		body.take_damage(damage * _current_charge_force_factor, Vector2(0,0))


func _on_ShieldRecoveryTimer_timeout() -> void:
	if _current_shield + _current_shield_recovery/2 > shield_capacity:
		_current_shield = shield_capacity
	elif _current_shield + _current_shield_recovery/2 <= shield_capacity:
		_current_shield += _current_shield_recovery/2
	bar_shield.value = _current_shield
