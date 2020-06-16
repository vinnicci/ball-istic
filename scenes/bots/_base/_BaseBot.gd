extends RigidBody2D


export (float, 20.0, 150.0) var bot_radius: float = 32.0 setget , get_bot_radius
export (float) var shield_capacity: float = 20 setget , get_shield_capacity
export (float) var health_capacity: float = 20 setget , get_health_capacity
export (int, 0, 3000) var speed: int = 1200 setget , get_speed
export (float) var shield_recovery_per_sec: float = 1.0 setget , get_shield_recovery_per_sec
export (float, 0.1, 1.0) var transform_speed: float = 0.6 setget , get_transform_speed
export (float, 0.5, 5.0) var charge_cooldown: float = 3.0 setget , get_charge_cooldown
export (float, 0, 1.0) var knockback_resist: float = 0.5 setget , get_knockback_resist
export (float, 0.1, 1.5) var charge_force_factor: float = 0.5 setget , get_charge_force_factor
export (float) var charge_damage_rate: float = 1.0 setget , get_charge_damage_rate
export (bool) var destructible: bool = true setget , is_destructible
export (Color) var faction: Color = Color(1, 0.13, 0.13) setget , get_faction
export (Color) var charge_outline: = Color(1, 0, 0.9) setget , get_charge_outline

const OUTLINE_SIZE: float = 4.5
const ROLLING_SPEED: float = 0.6
const ROLL_MODE_DAMP: float = 2.0
const TURRET_MODE_DAMP: float = 5.0
const POLY_SIDES = 24 #bot polygon has 24 points
const DEFAULT_BOT_RADIUS: float = 32.0
const DEFAULT_COMMIT_VELOCITY: float = 0.45
var _charge_commit_velocity: float
var _legs_position: Dictionary = {}

var current_shield: float
var current_health: float
var current_speed: int
var current_shield_recovery: float
var current_transform_speed: float
var current_charge_cooldown: float setget set_current_charge_cooldown, get_current_charge_cooldown
var current_knockback_resist: float
var current_charge_damage_rate: float
var current_charge_force_factor: float
var current_faction: Color
var current_weapon: Node
var velocity: Vector2
var _arr_weapons: Array = [null, null, null, null, null]

onready var _body_outline: = $Body/Outline
onready var _body_texture: = $Body/Texture
onready var _body_charge_effect: = $Body/ChargeEffect
onready var _body_weapon_hatch: = $Body/WeaponHatch
onready var _switch_tween: = $Body/SwitchTween
onready var _body_tween: = $Body/BodyTween
onready var _bar_shield: = $Bars/Shield
onready var _bar_health: = $Bars/Health
onready var _timer_charge_cooldown: = $Timers/ChargeCooldown
onready var timer_stun: = $Timers/Stun


###########################
# default export properties
###########################
func get_bot_radius():
	return bot_radius

func get_shield_capacity():
	return shield_capacity

func get_health_capacity():
	return health_capacity

func get_speed():
	return speed

func get_shield_recovery_per_sec():
	return shield_recovery_per_sec

func get_transform_speed():
	return transform_speed

func get_charge_cooldown():
	return charge_cooldown

func get_knockback_resist():
	return knockback_resist

func get_charge_damage_rate():
	return charge_damage_rate

func get_charge_force_factor():
	return charge_force_factor

func is_destructible():
	return destructible

func get_faction():
	return faction

func get_charge_outline():
	return charge_outline


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


###################
# bot state machine
###################
enum State {
	TURRET, ROLL, TO_TURRET, TO_ROLL, WEAP_COMMIT, CHARGE_ROLL, STUN, DEAD
}
var state = State.TURRET
var _before_stun = null


#state checker
func task_is_in_state(task):
	var get_state
	match task.get_param(0):
		"TURRET": get_state = State.TURRET
		"ROLL": get_state = State.ROLL
		"TO_TURRET": get_state = State.TO_TURRET
		"TO_ROLL": get_state = State.TO_ROLL
		"WEAP_COMMIT": get_state = State.WEAP_COMMIT
		"CHARGE_ROLL": get_state = State.CHARGE_ROLL
		"STUN": get_state = State.STUN
		"DEAD": get_state = State.DEAD
	if get_state == State.STUN && current_health > 0:
		$Labels/BotState.text = "STUNNED!"
	else:
		$Labels/BotState.text = ""
	if state == get_state:
		task.succeed()
	else:
		task.failed()
	return


#states enter and process tasks
func task_turret_process(task):
	if current_health <= 0 || timer_stun.is_stopped() == false:
		_before_stun = state
		state = State.STUN
		task.succeed()
		return
	if _switch == true:
		state = State.TO_ROLL
		task.succeed()
		return
	if current_weapon.weap_commit == true:
		state = State.WEAP_COMMIT
		task.succeed()
		return


func task_roll_process(task):
	if current_health <= 0 || timer_stun.is_stopped() == false:
		_before_stun = state
		state = State.STUN
		task.succeed()
		return
	if _switch == true:
		state = State.TO_TURRET
		task.succeed()
		return
	if _charge_roll != null:
		state = State.CHARGE_ROLL
		task.succeed()
		return


func task_to_turret_enter(task):
	_switch_to_turret()
	task.succeed()
	return


func task_to_turret_process(task):
	if current_health <= 0 || timer_stun.is_stopped() == false:
		_before_stun = state
		state = State.STUN
		task.succeed()
		return
	if _switch == false:
		state = State.TURRET
		task.succeed()
		return


func task_to_roll_enter(task):
	_switch_to_roll()
	task.succeed()
	return


func task_to_roll_process(task):
	if current_health <= 0 || timer_stun.is_stopped() == false:
		_before_stun = state
		state = State.STUN
		task.succeed()
		return
	if _switch == false:
		state = State.ROLL
		task.succeed()
		return


func task_weap_commit_process(task):
	if current_health <= 0 || timer_stun.is_stopped() == false:
		_before_stun = state
		state = State.STUN
		task.succeed()
		return
	if current_weapon.weap_commit == false:
		state = State.TURRET
		task.succeed()
		return


func task_charge_roll_process(task):
	if current_health <= 0:
		state = State.DEAD
		task.succeed()
		return
	if _charge_roll == null:
		state = State.ROLL
		task.succeed()
		return
	if timer_stun.is_stopped() == false:
		timer_stun.stop()


func task_stun_process(task):
	if current_health <= 0:
		state = State.DEAD
		task.succeed()
		return
	if timer_stun.is_stopped() == true:
		match _before_stun:
			State.ROLL, State.TO_ROLL:
				state = State.ROLL
			State.TURRET, State.TO_TURRET, State.WEAP_COMMIT:
				state = State.TURRET
		_before_stun = null
		task.succeed()
		return


func task_dead_enter(task):
	current_health = 0
	explode()
	task.succeed()
	return


func task_dead_process(task):
	task.reset()


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
		$AI.set_parent(self)
	
	#error: no explosion component
	if has_node("Explosion") == false:
		push_error(name + " has no explosion node. Please attach one.")
	
	#weapon components initialized here, some npc bots will have multiple weapons
	#must be child of Weapons node
	var initialized_selected_weap: = false
	var i: = -1
	for weapon in $Weapons.get_children():
		i += 1
		weapon.set_parent(self)
		_arr_weapons[i] = weapon
		if initialized_selected_weap == false:
			current_weapon = weapon
			initialized_selected_weap = true
			continue
		weapon.modulate = Color(1,1,1,0)
	
	#bot physics and properties
	mass = bot_radius / DEFAULT_BOT_RADIUS
	#makes sure even heavy bots can charge although at a much shorter distance
	_charge_commit_velocity = DEFAULT_COMMIT_VELOCITY / mass
	$CollisionShape.shape.radius = bot_radius
	$CollisionSpark/Particles2D.position = Vector2(bot_radius, 0)
	linear_damp = TURRET_MODE_DAMP
	angular_damp = TURRET_MODE_DAMP
	if destructible == false:
		$Bars/Shield.hide()
		$Bars/Health.hide()
	_body_outline.modulate = faction
	_body_weapon_hatch.modulate = faction
	
	#bot's body setup
	_body_texture.scale = Vector2(bot_radius/DEFAULT_BOT_RADIUS, bot_radius/DEFAULT_BOT_RADIUS)
	_bar_shield.rect_position.y += bot_radius + 15 #-> hardcoded for now
	_bar_health.rect_position.y += _bar_shield.rect_position.y + 15 #-> hardcoded for now
	var outline = bot_radius + OUTLINE_SIZE
	_body_outline.polygon = _plot_circle_points(outline)
	var cp = _plot_circle_points(bot_radius) #<- circle points
	_body_charge_effect.polygon = cp
	_body_weapon_hatch.polygon = [cp[0], cp[1], cp[2], cp[10], cp[11], cp[12],
		cp[13], cp[14], cp[22], cp[23]]
	_init_legs([cp[4], cp[12], cp[20]])


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
	if state == State.DEAD:
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
	current_charge_damage_rate = charge_damage_rate
	current_charge_force_factor = charge_force_factor
	
	current_speed = speed
	current_knockback_resist = knockback_resist
	
	current_faction = faction
	
	for weap in _arr_weapons:
		if weap == null:
			continue
		weap.current_heat = 0
	
	_cap_current_vars()


func _cap_current_vars() -> void:
	current_speed = clamp(current_speed, 500, 3000)
	current_transform_speed = clamp(current_transform_speed, 0.1, 1.0)
	current_charge_cooldown = clamp(current_charge_cooldown, 0.5, 5.0)
	current_knockback_resist = clamp(current_knockback_resist, 0, 1.0)
	current_charge_force_factor = clamp(current_charge_force_factor, 0.1, 2.0)


func _process(delta: float) -> void:
	$Labels.global_rotation = 0
	
	$Bars.global_rotation = 0
	
	$CollisionSpark.global_rotation = 0
	
	#rolling ball pseudo 3d effect
	_apply_rolling_effects(delta)
	
	#reset colors after charging
	_end_charging_effect()


#60 fps
func _physics_process(delta: float) -> void:
	pass


func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	#teleport
	if _teleport_pos != null:
		state.transform.origin = _teleport_pos
		_teleport_pos = null
	#velocity
	applied_force = Vector2(0,0)
	if self.state == State.ROLL:
		velocity = velocity.normalized()
		velocity *= current_speed
		applied_force = velocity
	velocity = Vector2(0,0)


#make sure to import body texture with repeating enabled
var _unrolled: bool = false


func _apply_rolling_effects(delta: float) -> void:
	if _check_if_turret() == true && _unrolled == false:
		_body_tween.interpolate_property(_body_texture, "texture_offset", _body_texture.texture_offset,
			Vector2(0,0), 0.1, Tween.TRANS_LINEAR)
		_body_tween.start()
		_unrolled = true
	else:
		_body_texture.texture_offset -= linear_velocity.rotated(-rotation) * (ROLLING_SPEED * delta)
		_unrolled = false


func _check_if_turret() -> bool:
	var output
	match state:
		State.TO_TURRET, State.TURRET, State.WEAP_COMMIT:
			output = true
		State.ROLL:
			output = false
		State.DEAD, State.STUN:
			match _before_stun:
				State.TURRET, State.TO_TURRET, State.WEAP_COMMIT:
					output = true
				State.TO_ROLL, State.ROLL:
					output = false
	return output


var _switch: bool = false


func switch_mode():
	if state == State.ROLL || state == State.TURRET:
		_switch = true


#state machine exclusive
func _switch_to_turret() -> void:
	velocity = Vector2(0,0)
	$Sounds/ChangeMode.play()
	linear_damp = TURRET_MODE_DAMP
	angular_damp = TURRET_MODE_DAMP
	mode = RigidBody2D.MODE_CHARACTER
	_animate_legs_to_turret()
	_animate_weapon_hatch_to_turret()


func _animate_legs_to_turret() -> void:
	for leg in _legs_position.keys():
		_switch_tween.interpolate_property(leg, 'position', Vector2(0,0), _legs_position[leg],
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func _animate_weapon_hatch_to_turret() -> void:
	if current_weapon != null:
		_body_weapon_hatch.global_rotation = current_weapon.global_rotation
		current_weapon.animate_transform(current_transform_speed)
	_body_weapon_hatch.show()
	_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
		current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


#state machine exclusive
func _switch_to_roll() -> void:
	velocity = Vector2(0,0)
	$Sounds/ChangeMode.play()
	linear_damp = ROLL_MODE_DAMP
	angular_damp = -1
	mode = RigidBody2D.MODE_RIGID
	_animate_legs_to_roll()
	_animate_weapon_hatch_to_roll()


func _animate_legs_to_roll() -> void:
	for leg in _legs_position.keys():
		_switch_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func _animate_weapon_hatch_to_roll() -> void:
	if current_weapon != null:
		current_weapon.global_rotation = _body_weapon_hatch.global_rotation
		current_weapon.animate_transform(current_transform_speed)
	_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
		current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func _on_SwitchTween_tween_all_completed() -> void:
	if state == State.TO_ROLL:
		_body_weapon_hatch.hide()
	_switch = false


func shoot_weapon() -> void:
	if state == State.TURRET:
		current_weapon.fire()


#some weapon has fixed anim -- will use shoot_commit var
func change_weapon(slot_num: int) -> bool:
	var weap = _arr_weapons[slot_num]
	if weap == null || state == State.TO_ROLL || state == State.TO_TURRET:
		return false
	current_weapon.modulate = Color(1,1,1,0)
	if state == State.TURRET:
		current_weapon = weap
		current_weapon.modulate = Color(1,1,1,1)
	elif state == State.ROLL:
		current_weapon = weap
	return true


var _charge_roll = null


#charge strength depends on speed and force multiplier
func charge_roll(charge_direction: float) -> void:
	if state != State.ROLL || is_charge_roll_ready() == false:
		return
	_charge_roll = charge_direction
	_apply_charge_impulse(_charge_roll)


func _apply_charge_impulse(dir: float) -> void:
	apply_central_impulse(Vector2(current_speed,0).rotated(dir) * current_charge_force_factor)
	$Timers/ChargeEffectDelay.start()
	$Sounds/ChargeAttack.play()
	_timer_charge_cooldown.start()


#0.05 sec delay in order to get almost peak linear velocity
func _on_ChargeEffectDelay_timeout() -> void:
	_peak_charge_roll()


func _peak_charge_roll() -> void:
	if linear_velocity.length() > current_speed * _charge_commit_velocity:
		$Timers/ChargeTrail.start()
		_body_outline.modulate = charge_outline
		_body_charge_effect.modulate.a = 1.0


func _on_ChargeTrail_timeout() -> void:
	_leave_trail(global_position)


func _end_charging_effect() -> void:
	#stun state is included because of discharge parry stun eventually
	if ((state == State.DEAD || state == State.CHARGE_ROLL || state == State.STUN) &&
		linear_velocity.length() <= current_speed * _charge_commit_velocity):
		_body_tween.interpolate_property(_body_outline, "modulate", _body_outline.modulate,
			current_faction, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_body_tween.interpolate_property(_body_charge_effect, "modulate", _body_charge_effect.modulate,
			Color(1,1,1,0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_body_tween.start()
		$Timers/ChargeTrail.stop()
		_charge_roll = null


#teleport
var _teleport_pos = null


func teleport(to_position: Vector2) -> void:
	_teleport_pos = to_position
	var current_pos = global_position
	while current_pos.distance_to(to_position) > bot_radius * 3:
		_leave_trail(current_pos)
		current_pos = current_pos.move_toward(to_position, bot_radius * 3)
	$Sounds/Teleport.play()


#trail effect used by charge roll and teleport
func _leave_trail(pos: Vector2) -> void:
	var trail = _body_charge_effect.duplicate()
	Global.current_level.add_child(trail)
	trail.global_position = pos
	trail.get_node("Anim").play("fade")
	trail.get_node("Anim").connect("animation_finished", Cleaner, "_on_Trail_anim_finished", [trail])


func apply_knockback(knockback: Vector2) -> void:
	apply_central_impulse(knockback - (knockback*current_knockback_resist))


func take_damage(damage: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	if destructible == false:
		$Sounds/ShieldDamage.play()
		return
	if state == State.DEAD:
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


func discharge_parry() -> void:
	if ((state == State.TURRET || state == State.TO_TURRET || state == State.WEAP_COMMIT) &&
		_timer_charge_cooldown.is_stopped() == true):
		_body_charge_effect.get_node("Anim").play("discharge_parry")
		$Sounds/DischargeParry.play()
		$Timers/DischargeParry.start()
		_timer_charge_cooldown.start()


func _on_Bot_body_entered(body: Node) -> void:
	if state != State.CHARGE_ROLL:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	if has_node("Camera2D") == true:
		$Camera2D.shake_camera(20, 0.05, 0.05, 1)
	var damage: float = ((current_speed * 0.0625 * current_charge_force_factor) *
		current_charge_damage_rate)
	if body is Global.CLASS_BOT:
		if current_faction == body.current_faction:
			return
		#if both bots are charging each other
		#or a charging bot hit a parrying bot, damage is reduced to 1%
		if (body.state == Global.CLASS_BOT.State.CHARGE_ROLL ||
			body.get_node("Timers/DischargeParry").is_stopped() == false):
			damage *= 0.01
			$Sounds/Clash.play()
	body.take_damage(damage, Vector2(0,0))
	$Sounds/ChargeAttackHit.play()
	$CollisionSpark/Particles2D.look_at(body.global_position)
	$CollisionSpark/SparkDelay.start()


#delay the spark effect for accuracy
func _on_SparkDelay_timeout() -> void:
	$CollisionSpark/Particles2D.emitting = true


func _on_ShieldRecoveryTimer_timeout() -> void: #<- rate 1sec/4
	if current_shield + current_shield_recovery * 0.25 > shield_capacity:
		current_shield = shield_capacity
	elif current_shield + current_shield_recovery * 0.25 <= shield_capacity:
		current_shield += current_shield_recovery * 0.25
	_bar_shield.value = current_shield
