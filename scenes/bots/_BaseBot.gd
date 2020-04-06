extends RigidBody2D


#make sure to import body texture with repeating enabled
export (float, 25.0, 100.0) var bot_radius: = 32.0
export (float) var shield_capacity: = 25
export (float) var health_capacity: = 25
export (int, 0, 3000) var roll_speed: = 1200
export (float) var shield_recovery_per_sec: = 1.0
export (float, 0.1, 1.0) var transform_speed: = 0.6
export (float, 0.25, 5.0) var charge_cooldown: = 2.5
export (float, 0, 1.0) var knockback_resist: = 0.2
export (float, 0.01, 0.1) var charge_damage_factor: = 0.03
export (float, 0.1, 1.5) var charge_force_factor: = 0.5
export (bool) var is_destructible: = true
export (bool) var is_hostile: = true

const DEFAULT_BOT_RADIUS: float = 32.0
const BARS_OFFSET: int = 15
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.75
const NO_EFFECT_VELOCITY_FACTOR: float = 0.7
const OUTLINE_SIZE: float = 4.0
const ROLLING_EFFECT_FACTOR: float = 0.01
const ROLL_MODE_DAMP: int = 2
const SHOOT_MODE_DAMP: int = 5
const POLY_SIDES = 24
var _legs_position: Dictionary = {}

var current_shield: float
var current_health: float
var current_roll_speed: int
var current_shield_recovery: float
var current_transform_speed: float
var current_charge_cooldown: float
var current_knockback_resist: float
var current_charge_damage_factor: float
var current_charge_force_factor: float
var current_weapon: Node

var velocity: Vector2
var roll_mode: bool = false
var is_alive: bool = true
var is_charging: bool = false
var is_transforming: bool = false
var is_in_control: bool = true
var dict_weapons: Dictionary = {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null
}
signal shooting

onready var body_outline: = $Body/Outline
onready var body_texture: = $Body/Texture
onready var body_charge_effect: = $Body/ChargeEffect
onready var body_weapon_hatch: = $Body/WeaponHatch
onready var bar_shield: = $Bars/Shield
onready var bar_health: = $Bars/Health
onready var timer_charge_cooldown: = $Timers/ChargeCooldown


func _ready() -> void:
	#initialize bot
	_init_bot()
	_reset_bot_vars()


func _init_bot() -> void:
	#weapons
	var initialized_selected_weap: = false
	var i: = -1
	for weapon in $Weapons.get_children():
		i += 1
		dict_weapons[i] = weapon
		if initialized_selected_weap == false:
			current_weapon = weapon
			initialized_selected_weap = true
			continue
		weapon.hide()
	
	#bot physics and properties
	$CollisionShape.shape.radius = bot_radius
	linear_damp = SHOOT_MODE_DAMP
	if is_destructible == false:
		$Bars.hide()
	
	#bot's body set up
	body_texture.scale = Vector2(bot_radius/DEFAULT_BOT_RADIUS, bot_radius/DEFAULT_BOT_RADIUS)
	body_texture.position = Vector2(-bot_radius, -bot_radius)
	bar_shield.rect_position.y += bot_radius + BARS_OFFSET
	bar_health.rect_position.y += bar_shield.rect_position.y + BARS_OFFSET
	var outline = bot_radius + OUTLINE_SIZE
	body_outline.polygon = _plot_circle_points(outline)
	body_outline.position = Vector2(-outline, -outline)
	body_outline.offset = Vector2(outline, outline)
	var circle_points = _plot_circle_points(bot_radius)
	body_charge_effect.polygon = circle_points
	body_charge_effect.position = Vector2(-bot_radius, -bot_radius)
	body_charge_effect.offset = Vector2(bot_radius, bot_radius)
	
	#other body initializations
	_init_legs([circle_points[4], circle_points[12], circle_points[20]])
	_init_hatch([circle_points[0], circle_points[1], circle_points[2], circle_points[10],
		circle_points[11], circle_points[12], circle_points[13], circle_points[14],
		circle_points[22], circle_points[23]])


func _init_legs(circle_points) -> void:
	var leg_sprite: = $Legs/Sprite
	var leg1: = $Legs/Leg1
	var leg2: = $Legs/Leg2
	var leg3: = $Legs/Leg3
	var deg: = 360.0/POLY_SIDES as float
	for i in circle_points.size():
		var leg = leg_sprite.duplicate(DUPLICATE_USE_INSTANCING)
		if i == 0:
			leg1.add_child(leg)
			leg1.position = circle_points[0]
			_legs_position[leg1] = circle_points[0]
			leg1.rotation = deg2rad(4*deg) #<-- circle degrees * index from circle_points[index]
		elif i == 1:
			leg2.add_child(leg)
			leg2.position = circle_points[1]
			_legs_position[leg2] = circle_points[1]
			leg2.rotation = deg2rad(12*deg)
		elif i == 2:
			leg3.add_child(leg)
			leg3.position = circle_points[2]
			_legs_position[leg3] = circle_points[2]
			leg3.rotation = deg2rad(20*deg)
	leg_sprite.hide()


func _init_hatch(circle_points: Array) -> void:
	body_weapon_hatch.polygon = circle_points


func _plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(POLY_SIDES):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*(360.0/POLY_SIDES))))
	return circle_points


func _reset_bot_vars() -> void:
	current_shield = shield_capacity
	bar_shield.max_value = shield_capacity
	bar_shield.value = current_shield
	current_shield_recovery = shield_recovery_per_sec
	
	current_health = health_capacity
	bar_health.max_value = health_capacity
	bar_health.value = current_health
	
	current_transform_speed = transform_speed
	if current_weapon != null:
		current_weapon.transform_speed = current_transform_speed
	
	current_charge_cooldown = charge_cooldown
	timer_charge_cooldown.wait_time = current_charge_cooldown
	current_charge_damage_factor = charge_damage_factor
	current_charge_force_factor = charge_force_factor
	
	current_roll_speed = roll_speed
	current_knockback_resist = knockback_resist
	
	cap_current_vars()


func cap_current_vars() -> void:
	current_roll_speed = clamp(current_roll_speed, 500, 3000)
	current_transform_speed = clamp(current_transform_speed, 0.1, 1.0)
	current_charge_cooldown = clamp(current_charge_cooldown, 0.5, 5.0)
	current_knockback_resist = clamp(current_knockback_resist, 0, 1.0)
	current_charge_damage_factor = clamp(current_charge_damage_factor, 0.01, 0.1)
	current_charge_force_factor = clamp(current_charge_force_factor, 0.1, 1.5)


func _process(delta: float) -> void:
	$Bars.global_rotation = 0
	
	#rolling sound effect
#	_apply_rolling_audio()
	
	#everything charge roll
	#graphical feedback/effects
	_apply_charging_effects()
	
	#rolling ball graphical effect
	_apply_rolling_effects()
	
	#high speed, transforming, and dying means losing control
	#makes charge roll an attack commitment
	_check_if_in_control()
	
	#velocity calculations
	if is_in_control == true:
		velocity = Vector2(0,0)
		_control(delta)


#60 fps
func _physics_process(delta: float) -> void:
	pass


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	_apply_force()


func _control(delta) -> void:
	if has_node("AI") == true:
		$AI._control(delta)


func _apply_rolling_audio() -> void:
	if linear_velocity.length() < 50:
		return
	$Sounds/Roll.play()


func _apply_force() -> void:
	applied_force = Vector2(0,0)
	if roll_mode == false:
		return
	#if for some reason velocities aren't normalized
	if velocity.is_normalized() == false:
		velocity = velocity.normalized() * current_roll_speed
	else:
		velocity *= current_roll_speed
	applied_force = velocity


func _apply_charging_effects() -> void:
	var color_hostile: = Color(1, 0.13, 0.13) #red
	var color_non_hostile: = Color(0.4, 1, 0.4) #green
	if linear_velocity.length() <= current_roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		if is_hostile == true: #outline for hostiles becomes red
			body_outline.color = lerp(body_outline.color, color_hostile, 0.8)
		elif is_hostile == false: #outline for non-hostiles becomes green
			body_outline.color = lerp(body_outline.color, color_non_hostile, 0.8)
		body_charge_effect.color.a = lerp(body_charge_effect.color.a, 0, 0.8)
		body_weapon_hatch.color = body_outline.color
		is_charging = false
	elif linear_velocity.length() > current_roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR:
		body_outline.color = Color(1, 0.24, 0.88)
		body_charge_effect.color.a = 255
		is_charging = true


func _apply_rolling_effects() -> void:
	if roll_mode == false:
		body_texture.texture_offset = lerp(body_texture.texture_offset, Vector2(0,0), 0.5)
		return
	if roll_mode == true:
		body_texture.texture_offset -= (linear_velocity.rotated(-rotation)/current_roll_speed) * (current_roll_speed * ROLLING_EFFECT_FACTOR)


#controls include weapon shooting
func _check_if_in_control() -> void:
	if is_alive == true && is_charging == false && is_transforming == false:
		is_in_control = true
	else:
		is_in_control = false


func switch_mode() -> void:
	is_in_control = false
	is_transforming = true
	$Sounds/ChangeMode.play()
	_animate_legs()
	_animate_weapon_hatch()
	roll_mode = !roll_mode
	if roll_mode == true:
		linear_damp = ROLL_MODE_DAMP
		mode = RigidBody2D.MODE_RIGID
	elif roll_mode == false:
		linear_damp = SHOOT_MODE_DAMP
		mode = RigidBody2D.MODE_CHARACTER


func _animate_legs() -> void:
	var leg_tween: = $Legs/LegTween
	if roll_mode == false:
		for leg in _legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
				current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()
	elif roll_mode == true:
		for leg in _legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', Vector2(0,0), _legs_position[leg],
				current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()


func _animate_weapon_hatch() -> void:
	var weapon_hatch_tween: = body_weapon_hatch.get_node("WeaponHatchTween")
	if roll_mode == false:
		if current_weapon != null:
			current_weapon.global_rotation = body_weapon_hatch.global_rotation
			current_weapon.visible = !current_weapon.visible
		weapon_hatch_tween.interpolate_property(body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif roll_mode == true:
		if current_weapon != null:
			body_weapon_hatch.global_rotation = current_weapon.global_rotation
			current_weapon.visible = !current_weapon.visible
		body_weapon_hatch.show()
		weapon_hatch_tween.interpolate_property(body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	weapon_hatch_tween.start()


func _on_WeaponHatchTween_tween_all_completed() -> void:
	if roll_mode == true:
		body_weapon_hatch.hide()
	is_transforming = false


func shoot_weapon() -> void:
	if is_in_control == false || current_weapon.get_node("ShootCooldown").is_stopped() == false || current_weapon.is_overheating == true || roll_mode == true:
		return
	var muzzle: = current_weapon.get_node("Muzzle")
	emit_signal("shooting", current_weapon.get_projectiles(), muzzle.global_position,
		muzzle.global_rotation, is_hostile)


func change_weapon(slot_num: int) -> void:
	var weap = dict_weapons[slot_num]
	if weap == null || weap == current_weapon:
		return
	if roll_mode == false:
		current_weapon.visible = !current_weapon.visible
	current_weapon = weap
	if roll_mode == false:
		current_weapon.visible = !current_weapon.visible


func charge_attack(charge_direction: float) -> void:
	if is_in_control == false || timer_charge_cooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(Vector2(current_roll_speed,0).rotated(charge_direction) * current_charge_force_factor)
	$Sounds/ChargeAttack.play()
	timer_charge_cooldown.start()


func take_damage(damage, knockback) -> void:
	if is_alive == false:
		$Sounds/HealthDamage.play()
		return
	apply_central_impulse(knockback - (knockback*current_knockback_resist))
	if is_destructible == false:
		return
	if current_shield - damage >= 0:
		$Sounds/ShieldDamage.play()
		current_shield -= damage
	elif current_shield - damage < 0:
		$Sounds/HealthDamage.play()
		current_health += current_shield - damage
		current_shield = 0
	bar_shield.value = current_shield
	bar_health.value = current_health
	if current_health <= 0:
		_explode()


func _explode() -> void:
	is_alive = false
	$Legs.modulate = Color(0.18, 0.18, 0.18)
	$Body.modulate = Color(0.18, 0.18, 0.18)
	$Bars.hide()
	$Timers/ExplodeDelay.start()


func _on_ExplodeDelay_timeout() -> void:
	if current_weapon != null:
		current_weapon.hide()
	$Legs.hide()
	$Body.hide()
	$Bars.hide()
	$CollisionShape.disabled = true
	
	#explosion effects here
	$Explosion.start_explosion()
	$Timers/ExplodeTimer.start()


func _on_ExplodeTimer_timeout() -> void:
	queue_free()


func _on_Bot_body_entered(body: Node) -> void:
	if is_charging == false:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	$Sounds/ChargeAttackHit.play()
	var damage = current_roll_speed as float * current_charge_damage_factor * current_charge_force_factor
	if body.get_parent().name == "Bots":
		if is_hostile == body.is_hostile:
			return
		elif is_hostile != body.is_hostile:
			body.take_damage(damage, Vector2(0,0))
	else:
		body.take_damage(damage, Vector2(0,0))


func _on_ShieldRecoveryTimer_timeout() -> void:
	if current_shield + current_shield_recovery/2 > shield_capacity:
		current_shield = shield_capacity
	elif current_shield + current_shield_recovery/2 <= shield_capacity:
		current_shield += current_shield_recovery/2
	bar_shield.value = current_shield
