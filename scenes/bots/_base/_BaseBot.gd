extends RigidBody2D


export (float, 20.0, 100.0) var bot_radius: = 32.0 setget , get_bot_radius
export (float) var shield_capacity: = 20 setget , get_shield_capacity
export (float) var health_capacity: = 20 setget , get_health_capacity
export (int, 0, 3000) var roll_speed: = 1200 setget , get_roll_speed
export (float) var shield_recovery_per_sec: = 1.0 setget , get_shield_recovery_per_sec
export (float, 0.1, 1.0) var transform_speed: = 0.6 setget , get_transform_speed
export (float, 0.5, 5.0) var charge_cooldown: = 3.0 setget , get_charge_cooldown
export (float, 0, 1.0) var knockback_resist: = 0.5 setget , get_knockback_resist
export (float) var charge_base_damage: = 20 setget , get_charge_base_damage
export (float, 0.1, 1.5) var charge_force_factor: = 0.5 setget , get_charge_force_factor
export (bool) var destructible: = true setget , is_destructible
export (bool) var hostile: = true setget , is_hostile

const DEFAULT_BOT_RADIUS: float = 32.0
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.68
const NO_EFFECT_VELOCITY_FACTOR: float = 0.63
const OUTLINE_SIZE: float = 4.5
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
var current_charge_cooldown: float setget set_current_charge_cooldown, get_current_charge_cooldown
var current_knockback_resist: float
var current_charge_base_damage: float
var current_charge_force_factor: float
var current_weapon: Node
var velocity: Vector2
var _arr_weapons: Array = [null, null, null, null, null]

onready var _body_outline: = $Body/Outline
onready var _body_texture: = $Body/Texture
onready var _body_charge_effect: = $Body/ChargeEffect
onready var _body_weapon_hatch: = $Body/WeaponHatch
onready var _switch_tween: = $Body/SwitchTween
onready var _charge_tween: = $Body/ChargeTween
onready var _bar_shield: = $Bars/Shield
onready var _bar_health: = $Bars/Health
onready var _timer_charge_cooldown: = $Timers/ChargeCooldown
onready var _timer_no_control: = $Timers/NoControlTimer


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

func get_charge_base_damage():
	return charge_base_damage

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
	current_charge_cooldown = new_charge_cooldown
	_timer_charge_cooldown.wait_time = new_charge_cooldown

func get_current_charge_cooldown():
	return current_charge_cooldown

func is_charge_roll_ready():
	return _timer_charge_cooldown.is_stopped()


############
# bot states
############
#special states:
#stun - a rather special status effect that interferes with control state
#fire_weapon - some weapon needs commitment when shot so bot temporarily lose control
enum BotState {
	TURRET, ROLL, CHARGE_ROLL, TRANSFORM, DEAD
}
enum ControlState {
	IN_CONTROL, NO_CONTROL
}
var control_state = ControlState.IN_CONTROL
var bot_state = BotState.TURRET
var prev_bot_state
signal bot_state_changed
signal control_state_changed


func _on_ControlState_changed(new_control_state: bool, no_control_time: float = 0) -> void:
	if bot_state == BotState.DEAD:
		return
	if new_control_state == false:
		if no_control_time > _timer_no_control.time_left:
			_timer_no_control.start(no_control_time)
		control_state = ControlState.NO_CONTROL
	elif new_control_state == true && _timer_no_control.is_stopped() == true:
		control_state = ControlState.IN_CONTROL
	match control_state:
		ControlState.IN_CONTROL: $Labels/ControlState.text = "in_control"
		ControlState.NO_CONTROL: $Labels/ControlState.text = "no_control"


func _on_NoControlTimer_timeout() -> void:
	control_state = ControlState.IN_CONTROL
	match control_state:
		ControlState.IN_CONTROL: $Labels/ControlState.text = "in_control"
		ControlState.NO_CONTROL: $Labels/ControlState.text = "no_control"


func _on_BotState_changed(new_bot_state) -> void:
	if bot_state == BotState.DEAD:
		return
	if bot_state == BotState.ROLL || bot_state == BotState.TURRET:
		prev_bot_state = bot_state
	bot_state = new_bot_state
	match bot_state:
		BotState.TURRET: $Labels/BotState.text = "turret"
		BotState.ROLL: $Labels/BotState.text = "roll"
		BotState.TRANSFORM: $Labels/BotState.text = "transform"
		BotState.CHARGE_ROLL: $Labels/BotState.text = "charge_roll"
		BotState.DEAD: $Labels/BotState.text = "dead"


################
# core functions
################
func _ready() -> void:
	#initialize bot
	_init_bot()
	reset_bot_vars()


func _init_bot() -> void:
	#initialize AI component
	if has_node("AI") == true:
		$AI.set_parent_node(self)
	
	#error: no explosion component
	if has_node("Explosion") == false:
		push_error(name + " has no explosion node. Please attach one.")
	
	#weapon components initialized here, some npc bots will have multiple weapons
	#must be child of Weapons
	var initialized_selected_weap: = false
	var i: = -1
	for weapon in $Weapons.get_children():
		i += 1
		weapon.set_parent_node(self)
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
		$Bars/Shield.hide()
		$Bars/Health.hide()
	if hostile == true:
		_body_outline.modulate = HOSTILE_COLOR
		_body_weapon_hatch.modulate = HOSTILE_COLOR
	else:
		_body_outline.modulate = NON_HOSTILE_COLOR
		_body_weapon_hatch.modulate = NON_HOSTILE_COLOR
	
	#bot's body setup
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
	if bot_state == BotState.DEAD:
		return
	
	current_shield = shield_capacity
	_bar_shield.max_value = shield_capacity
	_bar_shield.value = current_shield
	current_shield_recovery = shield_recovery_per_sec
	
	current_health = health_capacity
	_bar_health.max_value = health_capacity
	_bar_health.value = current_health
	
	current_transform_speed = transform_speed
	
	current_charge_cooldown = charge_cooldown
	_timer_charge_cooldown.wait_time = current_charge_cooldown
	current_charge_base_damage = charge_base_damage
	current_charge_force_factor = charge_force_factor
	
	current_roll_speed = roll_speed
	current_knockback_resist = knockback_resist
	
	for weap in _arr_weapons:
		if weap == null:
			continue
		weap.current_heat = 0
	
	_cap_current_vars()


func _cap_current_vars() -> void:
	current_roll_speed = clamp(current_roll_speed, 500, 3000)
	current_transform_speed = clamp(current_transform_speed, 0.1, 1.0)
	current_charge_cooldown = clamp(current_charge_cooldown, 0.5, 5.0)
	current_knockback_resist = clamp(current_knockback_resist, 0, 1.0)
	current_charge_force_factor = clamp(current_charge_force_factor, 0.1, 2.0)


func _process(delta: float) -> void:
	$Labels.global_rotation = 0
	
	$Bars.global_rotation = 0
	
	#rolling ball graphical effect
	_apply_rolling_effects(delta)
	
	#reset colors after charging
	_end_charging_effect()


#60 fps
func _physics_process(delta: float) -> void:
	pass
	


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	applied_force = Vector2(0,0)
	if control_state == ControlState.NO_CONTROL:
		return
	if bot_state == BotState.ROLL:
		velocity = velocity.normalized()
		velocity *= current_roll_speed
		applied_force = velocity
	velocity = Vector2(0,0)


#make sure to import body texture with repeating enabled
func _apply_rolling_effects(delta: float) -> void:
	if bot_state == BotState.TURRET:
		#magic number for now
		#formula is used on other funcs that involves lerp
		var lerp_time: float = 35.0 * (1 - pow(0.5, delta))
		_body_texture.texture_offset = lerp(_body_texture.texture_offset, Vector2(0,0), lerp_time)
		return
	if bot_state == BotState.ROLL:
		_body_texture.texture_offset -= linear_velocity.rotated(-rotation) * (ROLLING_SPEED * delta)


func switch_mode() -> void:
	if control_state == ControlState.NO_CONTROL:
		return
	emit_signal("control_state_changed", false, current_transform_speed)
	emit_signal("bot_state_changed", BotState.TRANSFORM)
	velocity = Vector2(0,0)
	$Sounds/ChangeMode.play()
	_animate_legs()
	_animate_weapon_hatch()
	if prev_bot_state == BotState.TURRET:
		linear_damp = ROLL_MODE_DAMP
		angular_damp = -1
		mode = RigidBody2D.MODE_RIGID
	elif prev_bot_state == BotState.ROLL:
		linear_damp = TURRET_MODE_DAMP
		angular_damp = TURRET_MODE_DAMP
		mode = RigidBody2D.MODE_CHARACTER


func _animate_legs() -> void:
	if prev_bot_state == BotState.TURRET:
		for leg in _legs_position.keys():
			_switch_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
				current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			_switch_tween.start()
	elif prev_bot_state == BotState.ROLL:
		for leg in _legs_position.keys():
			_switch_tween.interpolate_property(leg, 'position', Vector2(0,0), _legs_position[leg],
				current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			_switch_tween.start()


func _animate_weapon_hatch() -> void:
	if prev_bot_state == BotState.TURRET:
		if current_weapon != null:
			current_weapon.global_rotation = _body_weapon_hatch.global_rotation
			current_weapon.animate_transform(current_transform_speed)
		_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif prev_bot_state == BotState.ROLL:
		if current_weapon != null:
			_body_weapon_hatch.global_rotation = current_weapon.global_rotation
			current_weapon.animate_transform(current_transform_speed)
		_body_weapon_hatch.show()
		_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


#some weapons have fixed anim, so will change this later
func _on_SwitchTween_tween_all_completed() -> void:
	if prev_bot_state == BotState.TURRET:
		_body_weapon_hatch.hide()
		emit_signal("control_state_changed", true)
		emit_signal("bot_state_changed", BotState.ROLL)
	elif prev_bot_state == BotState.ROLL:
		emit_signal("control_state_changed", true)
		emit_signal("bot_state_changed", BotState.TURRET)


func shoot_weapon() -> void:
	if control_state == ControlState.IN_CONTROL && bot_state == BotState.TURRET:
		current_weapon.fire()


func change_weapon(slot_num: int) -> void:
	var weap = _arr_weapons[slot_num]
	if weap == null:
		return
	current_weapon.modulate = Color(1,1,1,0)
	current_weapon = weap
	if bot_state == BotState.TURRET:
		current_weapon.modulate = Color(1,1,1,1)


#charge strength depends on speed and force multiplier
func charge_roll(charge_direction: float) -> void:
	if bot_state != BotState.ROLL || control_state == ControlState.NO_CONTROL || _timer_charge_cooldown.is_stopped() == false:
		return
	apply_central_impulse(Vector2(current_roll_speed,0).rotated(charge_direction) * current_charge_force_factor)
	$Timers/ChargeEffectDelay.start()
	$Sounds/ChargeAttack.play()
	_timer_charge_cooldown.start()


#0.05 sec delay in order to get near peak linear velocity
func _on_ChargeEffectDelay_timeout() -> void:
	_peak_charge_roll()


func _peak_charge_roll() -> void:
	if linear_velocity.length() > current_roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR:
		$Timers/ChargeTrail.start()
		emit_signal("control_state_changed", false)
		emit_signal("bot_state_changed", BotState.CHARGE_ROLL)
		_body_outline.modulate = Color(1, 0.24, 0.88) #--> bright pink
		_body_charge_effect.modulate.a = 1.0


#trail effect
func _on_ChargeTrail_timeout() -> void:
	var trail = _body_charge_effect.duplicate()
	trail.get_node("Anim").play("fade")
	Global.current_level.add_child(trail)
	trail.get_node("RemoveTimer").start()
	trail.global_position = Vector2(global_position.x - bot_radius, global_position.y - bot_radius)
	trail.get_node("RemoveTimer").connect("timeout", Cleaner, "_on_Trail_RemoveTimer_timeout", [trail])


func _end_charging_effect() -> void:
	if bot_state == BotState.CHARGE_ROLL && linear_velocity.length() <= current_roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		#hostility color hardcoded for now, as a result no customization for outline color
		if hostile == true:
			_charge_tween.interpolate_property(_body_outline, "modulate", _body_outline.modulate,
				HOSTILE_COLOR, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		elif hostile == false:
			_charge_tween.interpolate_property(_body_outline, "modulate", _body_outline.modulate,
				NON_HOSTILE_COLOR, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_charge_tween.interpolate_property(_body_charge_effect, "modulate", _body_charge_effect.modulate,
			Color(1,1,1,0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_charge_tween.start()
		$Timers/ChargeTrail.stop()
		emit_signal("control_state_changed", true)
		emit_signal("bot_state_changed", BotState.ROLL)


func apply_knockback(knockback: Vector2) -> void:
	apply_central_impulse(knockback - (knockback*current_knockback_resist))


func take_damage(damage: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	if destructible == false:
		$Sounds/ShieldDamage.play()
		return
	if bot_state == BotState.DEAD:
		$Sounds/HealthDamage.play()
		return
	if current_shield - damage >= 0:
		$Sounds/ShieldDamage.play()
		current_shield -= damage
	elif current_shield - damage < 0:
		$Sounds/HealthDamage.play()
		current_health += current_shield - damage
		current_shield = 0
		if has_node("Camera2D") == true:
			$Camera2D.shake_camera(10, 0.05, 0.05, 1)
	_bar_shield.value = current_shield
	_bar_health.value = current_health
	if current_health <= 0:
		emit_signal("control_state_changed", false)
		emit_signal("bot_state_changed", BotState.DEAD)
		explode()


func explode() -> void:
	$Legs.modulate = Color(0.18, 0.18, 0.18)
	$Body.modulate = Color(0.18, 0.18, 0.18)
	$Bars.hide()
	$Timers/ExplodeDelay.start()


func _on_ExplodeDelay_timeout() -> void:
	if current_weapon != null:
		current_weapon.hide()
	for sound in $Sounds.get_children():
		if sound.is_playing() == true:
			sound.stop()
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
	if bot_state != BotState.CHARGE_ROLL:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	if has_node("Camera2D") == true:
		$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	$Sounds/ChargeAttackHit.play()
	$CollisionSpark.look_at(body.global_position)
	$CollisionSpark.emitting = true	
	if body is Global.CLASS_BOT && hostile == body.hostile:
		return
	
	#force factor multiplicative -- base damage factor additive
	#damage is 1/16 the current velocity magnitude times force factor then add the base damage
	var damage: float = (linear_velocity.length() * 0.0625 * current_charge_force_factor) + current_charge_base_damage
	
	#if both are charging, the damage is reduced to 1/8
	if body is Global.CLASS_BOT && body.bot_state == Global.CLASS_BOT.BotState.CHARGE_ROLL:
		damage *= 0.125
	body.take_damage(damage, Vector2(0,0))


func _on_ShieldRecoveryTimer_timeout() -> void: #<- rate 1sec/4
	if current_shield + current_shield_recovery * 0.25 > shield_capacity:
		current_shield = shield_capacity
	elif current_shield + current_shield_recovery * 0.25 <= shield_capacity:
		current_shield += current_shield_recovery * 0.25
	_bar_shield.value = current_shield
