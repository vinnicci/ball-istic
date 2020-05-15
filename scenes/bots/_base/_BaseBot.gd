extends RigidBody2D


export (float, 20.0, 100.0) var bot_radius: = 32.0 setget , get_bot_radius
export (float) var shield_capacity: = 20 setget , get_shield_capacity
export (float) var health_capacity: = 20 setget , get_health_capacity
export (int, 0, 3000) var roll_speed: = 1200 setget , get_roll_speed
export (float) var shield_recovery_per_sec: = 1.0 setget , get_shield_recovery_per_sec
export (float, 0.1, 1.0) var transform_speed: = 0.6 setget , get_transform_speed
export (float, 0.5, 5.0) var charge_cooldown: = 3.0 setget , get_charge_cooldown
export (float, 0, 1.0) var knockback_resist: = 0.5 setget , get_knockback_resist
export (float, 0.01, 0.15) var charge_damage_factor: = 0.05 setget , get_charge_damage_factor
export (float, 0.1, 1.5) var charge_force_factor: = 0.5 setget , get_charge_force_factor
export (bool) var destructible: = true setget , is_destructible
export (bool) var hostile: = true setget , is_hostile

const DEFAULT_BOT_RADIUS: float = 32.0
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.68
const NO_EFFECT_VELOCITY_FACTOR: float = 0.63
const OUTLINE_SIZE: float = 3.5
const ROLLING_SPEED: float = 0.6
const ROLL_MODE_DAMP: float = 2.0
const TURRET_MODE_DAMP: float = 5.0
const POLY_SIDES = 24
const HOSTILE_COLOR = Color(1, 0.13, 0.13)
const NON_HOSTILE_COLOR = Color(0.4, 1, 0.4)
var _legs_position: Dictionary = {}

var current_shield: float
var current_health: float
var current_roll_speed: int
var current_shield_recovery: float
var current_transform_speed: float
var _current_charge_cooldown: float setget set_current_charge_cooldown, get_current_charge_cooldown
var current_knockback_resist: float
var current_charge_damage_factor: float
var current_charge_force_factor: float
var current_weapon: Node
var velocity: Vector2
var _is_rolling: bool = false setget , is_rolling
var _is_alive: bool = true setget , is_alive
var _is_charge_rolling: bool = false setget , is_charge_rolling
var _is_transforming: bool = false setget , is_transforming
var _is_in_control: bool = true setget , is_in_control
var _arr_weapons: Array = [null, null, null, null, null]

onready var _body_outline: = $Body/Outline
onready var _body_texture: = $Body/Texture
onready var _body_charge_effect: = $Body/ChargeEffect
onready var _body_weapon_hatch: = $Body/WeaponHatch
onready var _bar_shield: = $Bars/Shield
onready var _bar_health: = $Bars/Health
onready var _timer_charge_cooldown: = $Timers/ChargeCooldown


###########################
# default export properties
###########################
func get_bot_radius():
	return bot_radius

func get_shield_capacity():
	return shield_capacity

func get_health_capacity():
	return health_capacity

func get_roll_speed():
	return roll_speed

func get_shield_recovery_per_sec():
	return shield_recovery_per_sec

func get_transform_speed():
	return transform_speed

func get_charge_cooldown():
	return charge_cooldown

func get_knockback_resist():
	return knockback_resist

func get_charge_damage_factor():
	return charge_damage_factor

func get_charge_force_factor():
	return charge_force_factor

func is_destructible():
	return destructible

func is_hostile():
	return hostile

####################
# current properties
####################
func set_current_charge_cooldown(new_charge_cooldown: float):
	_current_charge_cooldown = new_charge_cooldown
	_timer_charge_cooldown.wait_time = new_charge_cooldown

func get_current_charge_cooldown():
	return _current_charge_cooldown

func is_rolling():
	return _is_rolling

func is_alive():
	return _is_alive

func is_charge_rolling():
	return _is_charge_rolling

func is_transforming():
	return _is_transforming

func is_in_control():
	return _is_in_control

func is_charge_roll_ready():
	return _timer_charge_cooldown.is_stopped()


func _ready() -> void:
	#initialize bot
	_init_bot()
	reset_bot_vars()


func _init_bot() -> void:
	#weapons initialized here, some ai will have multiple weapons
	var initialized_selected_weap: = false
	var i: = -1
	for weapon in $Weapons.get_children():
		i += 1
		_arr_weapons[i] = weapon
		if initialized_selected_weap == false:
			current_weapon = weapon
			initialized_selected_weap = true
			continue
		weapon.hide()
	
	#bot physics and properties
	$CollisionShape.shape.radius = bot_radius
	$CollisionSpark.position = Vector2(bot_radius + 5, 0)
	linear_damp = TURRET_MODE_DAMP
	angular_damp = TURRET_MODE_DAMP
	if destructible == false:
		$Bars.hide()
	
	#bot's body look set up
	_body_texture.scale = Vector2(bot_radius/DEFAULT_BOT_RADIUS, bot_radius/DEFAULT_BOT_RADIUS)
	_body_texture.position = Vector2(-bot_radius, -bot_radius)
	_bar_shield.rect_position.y += bot_radius + 15 #-> hardcoded for now
	_bar_health.rect_position.y += _bar_shield.rect_position.y + 15 #-> hardcoded for now
	var outline = bot_radius + OUTLINE_SIZE
	_body_outline.polygon = _plot_circle_points(outline)
	_body_outline.position = Vector2(-outline, -outline)
	_body_outline.offset = Vector2(outline, outline)
	var cp = _plot_circle_points(bot_radius) #<- circle points
	_body_charge_effect.polygon = cp
	_body_charge_effect.position = Vector2(-bot_radius, -bot_radius)
	_body_charge_effect.offset = Vector2(bot_radius, bot_radius)
	_body_weapon_hatch.polygon = [cp[0], cp[1], cp[2], cp[10], cp[11], cp[12], cp[13], cp[14], cp[22], cp[23]]
	_init_legs([cp[4], cp[12], cp[20]])


#four-legged bot variant later??
func _init_legs(circle_points) -> void:
	var leg_sprite: = $Legs/Sprite
	var deg: = 360.0/POLY_SIDES as float
	for i in circle_points.size():
		var leg_node = get_node("Legs/Leg" + i as String)
		var leg_sprite_c = leg_sprite.duplicate(DUPLICATE_USE_INSTANCING)
		leg_node.add_child(leg_sprite_c)
		leg_node.position = circle_points[i]
		_legs_position[leg_node] = circle_points[i]
		match i:
			0: leg_node.rotation = deg2rad(4*deg) #<-- circle degrees * index from circle_points[index]
			1: leg_node.rotation = deg2rad(12*deg)
			2: leg_node.rotation = deg2rad(20*deg)
	leg_sprite.hide()


func _plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(POLY_SIDES):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*(360.0/POLY_SIDES))))
	return circle_points


#use only for initialization or in bot stations
func reset_bot_vars() -> void:
	current_shield = shield_capacity
	_bar_shield.max_value = shield_capacity
	_bar_shield.value = current_shield
	current_shield_recovery = shield_recovery_per_sec
	
	current_health = health_capacity
	_bar_health.max_value = health_capacity
	_bar_health.value = current_health
	
	current_transform_speed = transform_speed
	
	_current_charge_cooldown = charge_cooldown
	_timer_charge_cooldown.wait_time = _current_charge_cooldown
	current_charge_damage_factor = charge_damage_factor
	current_charge_force_factor = charge_force_factor
	
	current_roll_speed = roll_speed
	current_knockback_resist = knockback_resist
	
	_cap_current_vars()


func _cap_current_vars() -> void:
	current_roll_speed = clamp(current_roll_speed, 500, 3000)
	current_transform_speed = clamp(current_transform_speed, 0.1, 1.0)
	_current_charge_cooldown = clamp(_current_charge_cooldown, 0.5, 5.0)
	current_knockback_resist = clamp(current_knockback_resist, 0, 1.0)
	current_charge_damage_factor = clamp(current_charge_damage_factor, 0.01, 0.1)
	current_charge_force_factor = clamp(current_charge_force_factor, 0.1, 2.0)


func _process(delta: float) -> void:
	$Bars.global_rotation = 0
	
	#rolling ball graphical effect
	_apply_rolling_effects(delta)
	
	#control state
	_is_in_control = _check_if_in_control()


#60 fps
func _physics_process(delta: float) -> void:
	#everything charge roll
	#graphical feedback/effects
	#to be placed in process
	_end_charging_effect()
	
	#velocity calculations
	if _is_in_control == true:
		velocity = Vector2(0,0)
		_control(delta)


func _control(delta) -> void:
	if has_node("AI") == true: #<- attached ai node should be named "AI"
		$AI.control_ai(delta)


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	applied_force = Vector2(0,0)
	if _is_rolling == false:
		return
	if velocity.is_normalized() == false:
		velocity = velocity.normalized()
	velocity *= current_roll_speed
	set_applied_force(velocity)


#make sure to import body texture with repeating enabled
func _apply_rolling_effects(delta: float) -> void:
	if _is_rolling == false:
		var lerp_time: float = 35.0 * (1 - pow(0.5, delta))
		_body_texture.texture_offset = lerp(_body_texture.texture_offset, Vector2(0,0), lerp_time)
		return
	if _is_rolling == true:
		_body_texture.texture_offset -= linear_velocity.rotated(-rotation) * (ROLLING_SPEED * delta)


#false means losing control to rolling, shooting, charging and switching mode
#lose control to switching weapon slot on transforming only
#no effect to opening inventory
func _check_if_in_control() -> bool:
	var output: bool = _is_alive == true && _is_charge_rolling == false && _is_transforming == false
	if current_weapon != null:
		output = output && current_weapon.is_shooting() == false
	return output


func switch_mode() -> void:
	if _is_in_control == false:
		return
	_is_in_control = false #apply immediately as possible
	_is_transforming = true
	$Sounds/ChangeMode.play()
	_animate_legs()
	_animate_weapon_hatch()
	_is_rolling = !_is_rolling
	if _is_rolling == true:
		linear_damp = ROLL_MODE_DAMP
		angular_damp = -1
		mode = RigidBody2D.MODE_RIGID
	elif _is_rolling == false:
		linear_damp = TURRET_MODE_DAMP
		angular_damp = TURRET_MODE_DAMP
		mode = RigidBody2D.MODE_CHARACTER


func _animate_legs() -> void:
	var leg_tween: = $Legs/LegTween
	if _is_rolling == false:
		for leg in _legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
				current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()
	elif _is_rolling == true:
		for leg in _legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', Vector2(0,0), _legs_position[leg],
				current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()


func _animate_weapon_hatch() -> void:
	var weapon_hatch_tween: = _body_weapon_hatch.get_node("WeaponHatchTween")
	if _is_rolling == false:
		if current_weapon != null:
			current_weapon.animate_transform(current_transform_speed)
		weapon_hatch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif _is_rolling == true:
		if current_weapon != null:
			current_weapon.animate_transform(current_transform_speed)
			_body_weapon_hatch.global_rotation = current_weapon.global_rotation
		_body_weapon_hatch.show()
		weapon_hatch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	weapon_hatch_tween.start()


#some weapons have longer anim than hatch, so will change this later
func _on_WeaponHatchTween_tween_all_completed() -> void:
	if _is_rolling == true:
		_body_weapon_hatch.hide()
	_is_transforming = false


#some weapons' shooting mode aren't auto, so will change this later
func shoot_weapon() -> void:
	if _is_in_control == true && _is_rolling == false:
		current_weapon.fire()


func change_weapon(slot_num: int) -> void:
	var weap = _arr_weapons[slot_num]
	if weap == null:
		return
	if _is_rolling == false:
		current_weapon.visible = false
	current_weapon = weap
	if _is_rolling == false:
		current_weapon.look_at(get_global_mouse_position())
		current_weapon.visible = true


func charge_roll(charge_direction: float) -> void:
	if _is_in_control == false || _timer_charge_cooldown.is_stopped() == false || _is_rolling == false:
		return
	apply_central_impulse(Vector2(current_roll_speed,0).rotated(charge_direction) * current_charge_force_factor)
	$Timers/ChargeEffectDelay.start()
	$Sounds/ChargeAttack.play()
	_timer_charge_cooldown.start()


signal charged


#0.05 sec delay in order to get almost peak linear velocity
func _on_ChargeEffectDelay_timeout() -> void:
	emit_signal("charged")


func _on_Bot_charged() -> void:
	if linear_velocity.length() > current_roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR:
		_is_in_control = false
		_is_charge_rolling = true
		_body_outline.color = Color(1, 0.24, 0.88)
		_body_charge_effect.color.a = 255


func _end_charging_effect() -> void:
	if linear_velocity.length() <= current_roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		#hostility color hardcoded for now, as a result no customization for outline color
		#will change later
		if hostile == true:
			_body_outline.color = lerp(_body_outline.color, HOSTILE_COLOR, 0.8)
		elif hostile == false:
			_body_outline.color = lerp(_body_outline.color, NON_HOSTILE_COLOR, 0.8)
		_body_charge_effect.color.a = lerp(_body_charge_effect.color.a, 0, 0.8)
		_body_weapon_hatch.color = _body_outline.color
		_is_charge_rolling = false


func take_damage(damage: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	if destructible == false:
		$Sounds/ShieldDamage.play()
		return
	if _is_alive == false:
		$Sounds/HealthDamage.play()
		return
	if current_shield - damage >= 0:
		$Sounds/ShieldDamage.play()
		current_shield -= damage
	elif current_shield - damage < 0:
		$Sounds/HealthDamage.play()
		current_health += current_shield - damage
		current_shield = 0
	_bar_shield.value = current_shield
	_bar_health.value = current_health
	if current_health <= 0:
		_explode()


func apply_knockback(knockback: Vector2) -> void:
	apply_central_impulse(knockback - (knockback*current_knockback_resist))


func _explode() -> void:
	_is_alive = false
	_is_in_control = false
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
	mode = RigidBody2D.MODE_STATIC
	
	#explosion effects here
	$Explosion.start_explosion()
	$Timers/ExplodeTimer.start()


func _on_ExplodeTimer_timeout() -> void:
	queue_free()


func _on_Bot_body_entered(body: Node) -> void:
	if _is_charge_rolling == false:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	if body is Global.CLASS_BOT && hostile == body.hostile:
		return
	var damage = current_roll_speed as float * current_charge_damage_factor * current_charge_force_factor
	if body is Global.CLASS_BOT && body._is_charge_rolling == true:
		damage /= 8
	body.take_damage(damage, Vector2(0,0))
	$Sounds/ChargeAttackHit.play()
	$CollisionSpark.look_at(body.global_position)
	$CollisionSpark.emitting = true


func _on_ShieldRecoveryTimer_timeout() -> void: #<- rate 1sec/4
	if current_shield + current_shield_recovery/4 > shield_capacity:
		current_shield = shield_capacity
	elif current_shield + current_shield_recovery/4 <= shield_capacity:
		current_shield += current_shield_recovery/4
	_bar_shield.value = current_shield
