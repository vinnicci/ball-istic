extends RigidBody2D


export (float, 20.0, 150.0) var bot_radius: float = 32.0 setget , get_bot_radius
export (float) var shield_capacity: float = 20 setget , get_shield_capacity
export (float) var shield_recovery_per_sec: float = 1.0 setget , get_shield_recovery_per_sec
export (float) var health_capacity: float = 20 setget , get_health_capacity
export (int, 0, 4000) var speed: int = 1200 setget , get_speed
export (float, 0, 1.0) var knockback_resist: float = 0.3 setget , get_knockback_resist
export (float, 0.05, 1.0) var transform_speed: float = 0.6 setget , get_transform_speed
export (float, 0.5, 5.0) var charge_cooldown: float = 3.0 setget , get_charge_cooldown
export (float, 0.1, 2.0) var charge_force_factor: float = 0.5 setget , get_charge_force_factor
export (float) var charge_crit_mult: float = 2 setget , get_charge_crit_mult
export (float, 0, 1.0) var charge_crit_chance: float = 0.2 setget , get_charge_crit_chance
export (float) var charge_damage_rate: float = 0.3 setget , get_charge_damage_rate
export (bool) var destructible: bool = true setget , is_destructible
export (Color) var faction: Color = Color(1, 0, 0) setget , get_faction
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

var current_shield_cap: float
var current_shield: float
var current_health_cap: float
var current_health: float
var current_speed: int
var current_shield_recovery: float
var current_transform_speed: float
var current_charge_cooldown: float setget set_current_charge_cooldown, get_current_charge_cooldown
var current_knockback_resist: float
var current_charge_damage_rate: float
var current_charge_force_factor: float
var current_charge_crit_mult: float
var current_charge_crit_chance: float
var current_faction: Color
var current_weapon: Node
var velocity: Vector2
var arr_weapons: Array = [null, null, null, null, null]
var level_node: Node = null

onready var _body_outline: = $Body/Outline
onready var _body_texture: = $Body/Texture
onready var _body_charge_effect: = $Body/ChargeEffect
onready var _body_weapon_hatch: = $Body/WeaponHatch
onready var _switch_tween: = $Body/SwitchTween
onready var _body_tween: = $Body/BodyTween
onready var bar_shield: = $Bars/Shield
onready var bar_health: = $Bars/Health
onready var _timer_charge_cooldown: = $Timers/ChargeCooldown
onready var _timer_discharge_parry: = $Timers/DischargeParry
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

func get_charge_crit_mult():
	return charge_crit_mult

func get_charge_crit_chance():
	return charge_crit_chance

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
	ROLL, TO_TURRET, TURRET, TO_ROLL, WEAP_COMMIT, CHARGE_ROLL, STUN, DEAD
}
var state = State.ROLL
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
	
	#when bot is initialized, turret is supposedly the default state
	#but with lines below, it now starts on roll state
	current_transform_speed = 0
	_switch_to_roll()
	$Sounds/ChangeMode.stop()
	
	#apply export vars
	reset_bot_vars()


func set_level(new_level: Node) -> void:
	level_node = new_level
	if has_node("Explosion") == true:
		$Explosion.set_level_cam(level_node.get_node("Camera2D"))
	if has_node("AI") == true:
		$AI.set_level(level_node)


func _init_bot() -> void:
	var state_machine = load("res://scenes/bots/_base/StateMachine.tscn")
	add_child(state_machine.instance())
	
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
		arr_weapons[i] = weapon
		if initialized_selected_weap == false:
			current_weapon = weapon
			initialized_selected_weap = true
			continue
		weapon.modulate = Color(1,1,1,0)
	
	#bot physics and properties
	$CollisionShape.shape = CircleShape2D.new()
	$CollisionShape.shape.radius = bot_radius
#	$CollisionSpark.position = Vector2(bot_radius + 5, 0)
	linear_damp = TURRET_MODE_DAMP
	angular_damp = TURRET_MODE_DAMP
	if destructible == false:
		$Bars/Shield.hide()
		$Bars/Health.hide()
	
	#bot's body graphics setup
	_body_texture.scale = Vector2(bot_radius/DEFAULT_BOT_RADIUS, bot_radius/DEFAULT_BOT_RADIUS)
	bar_shield.rect_position.y += bot_radius + 15 #-> 15 is hardcoded for now
	bar_health.rect_position.y += bar_shield.rect_position.y + 15
	bar_shield.margin_left = -bot_radius
	bar_shield.margin_right = bot_radius
	bar_health.margin_left = -bot_radius
	bar_health.margin_right = bot_radius
	bar_shield.rect_scale.x = (bot_radius*2)/150 #-> 150 is the bar length in pixels
	bar_health.rect_scale.x = (bot_radius*2)/150
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
		var leg_sprite_c = leg_sprite.duplicate()
		leg_node.add_child(leg_sprite_c)
		leg_node.position = circle_points[i]
		#store leg pos in dictionary
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
	
	#for the upcoming core mod implementation be sure to always add mass
	mass = mass * (bot_radius / DEFAULT_BOT_RADIUS)
	#makes sure even heavy bots can charge although at a shorter distance
	_charge_commit_velocity = DEFAULT_COMMIT_VELOCITY / mass
	
	current_shield_cap = shield_capacity
	current_shield = current_shield_cap
	bar_shield.max_value = current_shield_cap
	bar_shield.value = current_shield
	current_shield_recovery = shield_recovery_per_sec
	
	current_health_cap = health_capacity
	current_health = current_health_cap
	bar_health.max_value = current_health_cap
	bar_health.value = current_health
	
	current_transform_speed = transform_speed
	
	current_charge_cooldown = charge_cooldown
	_timer_charge_cooldown.wait_time = current_charge_cooldown
	current_charge_damage_rate = charge_damage_rate
	current_charge_force_factor = charge_force_factor
	current_charge_crit_mult = charge_crit_mult
	current_charge_crit_chance = charge_crit_chance
	
	current_speed = speed
	current_knockback_resist = knockback_resist
	
	current_faction = faction
	_body_outline.modulate = current_faction
	_body_weapon_hatch.modulate = current_faction
	
	for weap in arr_weapons:
		if weap == null:
			continue
		weap.reset_weap_vars()
	
	_cap_current_vars()


func _cap_current_vars() -> void:
	current_health_cap = clamp(current_health_cap, 1, 9999)
	current_health = clamp(current_health, 1, 9999)
	current_shield_cap = clamp(current_shield_cap, 0, 9999)
	current_shield = clamp(current_shield, 0, 9999)
	current_speed = clamp(current_speed, 500, 4000)
	current_transform_speed = clamp(current_transform_speed, 0.05, 1.0)
	current_charge_cooldown = clamp(current_charge_cooldown, 0.5, 5.0)
	current_knockback_resist = clamp(current_knockback_resist, 0, 1.0)
	current_charge_damage_rate = clamp(current_charge_damage_rate, 0, 1.0)
	current_charge_force_factor = clamp(current_charge_force_factor, 0.1, 2.0)


func _process(delta: float) -> void:
	$Bars.global_rotation = 0
	
	#rolling ball sliding texture
	_apply_rolling_effects(delta)
	
	#reset colors after charging
	_end_charging_effect()


var _is_ccd_on: bool = false


#ccd may be able to prevent wall phasing on fast moving bots
func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 2800 && _is_ccd_on == false:
		continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
		_is_ccd_on = true
	elif linear_velocity.length() <= 2800 && _is_ccd_on == true:
		continuous_cd = RigidBody2D.CCD_MODE_DISABLED
		_is_ccd_on = false


func _integrate_forces(pstate: Physics2DDirectBodyState) -> void:
	#teleport
	if _teleport_pos != null:
		pstate.transform.origin = _teleport_pos
		_teleport_pos = null
	#velocity
	applied_force = Vector2(0,0)
	if state == State.ROLL:
		velocity = velocity.normalized()
		velocity *= current_speed
		applied_force = velocity
	velocity = Vector2(0,0)


#make sure to import body texture with repeating enabled
var _unrolled: bool = false


func _apply_rolling_effects(delta: float) -> void:
	if _unrolled == false && _check_if_turret() == true:
		#the while loops simply reset texture offset near Vector(0,0)
		while _body_texture.texture_offset.x <= -bot_radius:
			_body_texture.texture_offset.x += bot_radius
		while _body_texture.texture_offset.x > bot_radius:
			_body_texture.texture_offset.x -= bot_radius
		while _body_texture.texture_offset.y <= -bot_radius:
			_body_texture.texture_offset.y += bot_radius
		while _body_texture.texture_offset.y > bot_radius:
			_body_texture.texture_offset.y -= bot_radius
		_body_tween.interpolate_property(_body_texture, "texture_offset", _body_texture.texture_offset,
			Vector2(0,0), 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		_body_tween.start()
		_unrolled = true
	elif _check_if_turret() == false:
		_body_texture.texture_offset -= linear_velocity.rotated(-rotation) * (ROLLING_SPEED * delta)
		_unrolled = false


func _check_if_turret() -> bool:
	var output
	match state:
		State.TO_TURRET, State.TURRET, State.WEAP_COMMIT:
			output = true
		State.ROLL, State.TO_ROLL:
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


#state machine exclusive func
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
		current_weapon.animate_transform(current_transform_speed, true)
	_body_weapon_hatch.show()
	_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
		current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


#state machine exclusive func
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
		current_weapon.animate_transform(current_transform_speed, false)
	_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
		current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func _on_SwitchTween_tween_all_completed() -> void:
	if state == State.TO_ROLL:
		_body_weapon_hatch.hide()
	_switch = false


func shoot_weapon() -> void:
	if state == State.TURRET:
		if current_weapon.level_node != level_node:
			current_weapon.level_node = level_node
		current_weapon.fire()


#some weapon have longer deploy animation -- will use shoot_commit var
func change_weapon(slot_num: int) -> bool:
	var weap = arr_weapons[slot_num]
	if weap == null:
		return false
	#can't switch weapon if in these states
	match state:
		State.TO_ROLL, State.TO_TURRET, State.STUN, State.WEAP_COMMIT, State.DEAD:
			return false
	current_weapon.modulate = Color(1,1,1,0)
	if state == State.TURRET:
		current_weapon = weap
		current_weapon.modulate = Color(1,1,1,1)
	elif state == State.ROLL || state == State.CHARGE_ROLL:
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
	_play_anim(global_position, _body_charge_effect.duplicate(), "trail")


func _end_charging_effect() -> void:
	#stun state is included because of discharge parry/stun riposte?? eventually
	if ((state == State.DEAD || state == State.CHARGE_ROLL || state == State.STUN) &&
		linear_velocity.length() <= current_speed * _charge_commit_velocity):
		_body_tween.interpolate_property(_body_outline, "modulate", _body_outline.modulate,
			current_faction, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_body_tween.interpolate_property(_body_charge_effect, "modulate",
			_body_charge_effect.modulate, Color(1,1,1,0), 0.1, Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT)
		_body_tween.start()
		$Timers/ChargeTrail.stop()
		_charge_roll = null


var _teleport_pos = null


func teleport(to_position: Vector2) -> void:
	_teleport_pos = to_position
	var current_pos = global_position
	while current_pos.distance_to(to_position) > bot_radius * 3:
		_play_anim(current_pos, _body_charge_effect.duplicate(), "trail")
		current_pos = current_pos.move_toward(to_position, bot_radius * 3)
	$Sounds/Teleport.play()


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
	bar_shield.value = current_shield
	bar_health.value = current_health


func discharge_parry() -> void:
	if _timer_charge_cooldown.is_stopped() == true:
		match state:
			State.TURRET, State.TO_TURRET, State.WEAP_COMMIT, State.TO_ROLL:
				_body_charge_effect.get_node("Anim").play("discharge_parry")
				$Sounds/DischargeParry.play()
				_timer_discharge_parry.start()
				_timer_charge_cooldown.start()


func _on_Bot_body_entered(body: Node) -> void:
	if state != State.CHARGE_ROLL:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	$CollisionSpark.position = (
		(body.position - position).normalized() * bot_radius)
	$CollisionSpark.emitting = true
	$Sounds/ChargeAttackHit.play()
	var damage: float = ((current_speed * 0.125 * current_charge_force_factor) *
		current_charge_damage_rate)
	#apply crit dmg
	if rand_range(0, 1.0) <= current_charge_crit_chance:
		damage *= current_charge_crit_mult
		if body is Global.CLASS_BOT:
			_play_anim(body.global_position, _crit_feedback.instance(), "critical")
	if body is Global.CLASS_BOT:
		if current_faction == body.current_faction:
			return
		#if both bots are charging each other
		#or a charging bot hit a parrying bot, damage is reduced to 1%
		if body.state == Global.CLASS_BOT.State.CHARGE_ROLL:
			_play_anim(global_position, _deflect_feedback.instance(), "deflect")
			return
		elif body.get_node("Timers/DischargeParry").is_stopped() == false:
			var dir: float = (global_position - body.global_position).angle()
			apply_knockback(Vector2(1500, 0).rotated(dir))
			_play_anim(global_position, _deflect_feedback.instance(), "deflect")
			return
	body.take_damage(damage, Vector2(0,0))
	if body.has_node("AI") == true:
		body.get_node("AI").engage_attacker(self)


var _crit_feedback = preload("res://scenes/global/feedback/Critical.tscn")
var _deflect_feedback = preload("res://scenes/global/feedback/Deflect.tscn")


func _play_anim(pos: Vector2, anim_instance: Node, anim_name: String) -> void:
	level_node.add_child(anim_instance)
	var anim = anim_instance.get_node("Anim")
	anim_instance.global_position = pos
#	crit_node.global_rotation = 0
	anim.connect("animation_finished", level_node, "_on_Anim_finished",
		[anim_instance])
	anim.play(anim_name)


func _on_ShieldRecoveryTimer_timeout() -> void: #<- rate 1sec/4
	if current_shield_recovery <= 0 || current_shield_cap <= 0:
		return
	if current_shield + current_shield_recovery * 0.25 > current_shield_cap:
		current_shield = current_shield_cap
	elif current_shield + current_shield_recovery * 0.25 <= current_shield_cap:
		current_shield += current_shield_recovery * 0.25
	bar_shield.value = current_shield


signal dead


func explode() -> void:
	var color = Color(0.18, 0.18, 0.18)
	if current_weapon != null && current_weapon.modulate.a > 0:
		var alpha = current_weapon.modulate.a
		current_weapon.modulate = color
		current_weapon.modulate.a = alpha
	$Legs.modulate = color
	$Body.modulate = color
	$Bars.hide()
	$Timers/ExplodeDelay.start()
	emit_signal("dead")
	if is_instance_valid(level_node.get_player()) == true:
		$Explosion.set_player_cam(level_node.get_player().get_node("Camera2D"))


func _on_ExplodeDelay_timeout() -> void:
	$CollisionShape.disabled = true
	if current_weapon != null:
		current_weapon.hide()
	$Legs.hide()
	$Body.hide()
	mode = RigidBody2D.MODE_STATIC
	#explosion effects here
	$Explosion/Blast/Anim.connect("animation_finished", self, "_on_Explode_finished")
	$Explosion.start_explosion()


func _on_Explode_finished(anim_name: String) -> void:
	queue_free()
