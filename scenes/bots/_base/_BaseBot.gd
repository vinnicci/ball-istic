extends RigidBody2D


export (int, 20, 150) var bot_radius: int = 32 setget , get_bot_radius
export (float) var shield_cap: float = 15 setget , get_shield_cap
export (float) var shield_regen: float = 1.0 setget , get_shield_regen
export (float) var health_cap: float = 15 setget , get_health_cap
export (int, 0, 9999) var speed: int = 1000 setget , get_speed
export (float, 0, 1.0) var transform_speed: float = 0.7 setget , get_transform_speed
export (float, 0.3, 5.0) var charge_cooldown: float = 3.5 setget , get_charge_cooldown
export (float, 0.1, 1.5) var charge_force_mult: float = 0.5 setget , get_charge_force_mult
export (float) var charge_crit_mult: float = 2 setget , get_charge_crit_mult
export (float, 0, 1.0) var charge_crit_chance: float = 0.2 setget , get_charge_crit_chance
export (float) var charge_dmg_rate: float = 0.2 setget , get_charge_dmg_rate
export (float) var weap_dmg_rate: float = 1 setget , get_weap_dmg_rate
export (float, 0, 1.0) var dmg_resist: float = 0 setget , get_dmg_resist
export (float, 0, 1.0) var knockback_resist: float = 0 setget , get_knockback_resist
export (bool) var destructible: bool = true
export (bool) var respawnable: bool = true
export (bool) var deployed: bool = false
export (Color) var faction: Color = Color(1, 0, 0) setget , get_faction
export (Color) var charge_outline: = Color(1, 0, 0.9) setget , get_charge_outline

const OUTLINE_SIZE: int = 6
const ROLLING_SPEED: float = 0.6
const ROLL_MODE_DAMP: int = 2
const TURRET_MODE_DAMP: int = 10
const POLY_SIDES: int = 24 #bot polygon has 24 points
const DEFAULT_BOT_RADIUS: int = 32
const DEFAULT_COMMIT_VELOCITY: float = 0.45
var _charge_commit_velocity: float
var _legs_position: Dictionary = {}

var current_shield_cap: float
var current_shield: float setget set_current_shield, get_current_shield
var current_health_cap: float
var current_health: float setget set_current_health, get_current_health
var current_dmg_resist: float
var current_speed: int
var current_shield_regen: float
var current_transform_speed: float
var current_charge_cooldown: float setget set_current_charge_cooldown, get_current_charge_cooldown
var current_knockback_resist: float
var current_charge_dmg_rate: float
var current_weap_dmg_rate: float
var current_charge_force_mult: float
var current_charge_crit_mult: float
var current_charge_crit_chance: float
var current_faction: Color
var current_weapon: Node
var velocity: Vector2
var arr_weapons: Array = [null, null, null, null, null]
var _level_node: Node
enum State {
	ROLL, TO_TURRET, TURRET, TO_ROLL, WEAP_COMMIT, CHARGE_ROLL, STUN, DEAD
}
var state

onready var _body_outline: = $Body/Outline
onready var _body_texture: = $Body/Texture
onready var _body_charge_effect: = $Body/ChargeEffect
onready var _body_weapon_hatch: = $Body/WeaponHatch
onready var _switch_tween: = $Body/SwitchTween
onready var bar_shield: = $Bars/Shield
onready var bar_health: = $Bars/Health
onready var _timer_charge_cooldown: = $Timers/ChargeCooldown
onready var timer_discharge_parry: = $Timers/DischargeParry
onready var timer_stun: = $Timers/Stun


###########################
# default export properties
###########################
func get_bot_radius():
	return bot_radius

func get_shield_cap():
	return shield_cap

func get_health_cap():
	return health_cap

func get_dmg_resist():
	return dmg_resist

func get_speed():
	return speed

func get_shield_regen():
	return shield_regen

func get_transform_speed():
	return transform_speed

func get_charge_cooldown():
	return charge_cooldown

func get_knockback_resist():
	return knockback_resist

func get_charge_dmg_rate():
	return charge_dmg_rate

func get_weap_dmg_rate():
	return weap_dmg_rate

func get_charge_force_mult():
	return charge_force_mult

func get_charge_crit_mult():
	return charge_crit_mult

func get_charge_crit_chance():
	return charge_crit_chance

func get_faction():
	return faction

func get_charge_outline():
	return charge_outline


####################
# current properties
####################
func set_current_shield(value: float):
	current_shield = value
	bar_shield.max_value = current_shield
	bar_shield.value = current_shield

func get_current_shield():
	return current_shield

func set_current_health(value: float):
	current_health = value
	bar_health.max_value = current_health
	bar_health.value = current_health

func get_current_health():
	return current_health

func set_current_charge_cooldown(new_charge_cooldown: float):
	current_charge_cooldown = new_charge_cooldown
	current_charge_cooldown = clamp(current_charge_cooldown, 0.3, 5.0)
	_timer_charge_cooldown.wait_time = current_charge_cooldown

func get_current_charge_cooldown():
	return current_charge_cooldown

func is_charge_roll_ready():
	return _timer_charge_cooldown.is_stopped()


func _ready() -> void:
	#initialize bot
	_init_bot()
	
	#when bot is initialized, turret is supposedly the default state
	#but with lines below, it now starts on roll state
	if deployed == false:
		state = State.ROLL
		current_transform_speed = 0
		switch_to_roll()
	else:
		state = State.TURRET
	$Sounds/ChangeMode.stop()
	
	#apply export vars
	reset_bot_vars()


func set_level(new_level: Node) -> void:
	_level_node = new_level
	if has_node("Explosion") == true:
		$Explosion.set_level_cam(_level_node.get_node("Camera2D"))
	if has_node("AI") == true:
		$AI.set_level(_level_node)
	for weapon in $Weapons.get_children():
		weapon.set_level(_level_node)


func _init_bot() -> void:
	#initialize state machine
	$StateMachine.set_bot(self)
	
	#initialize weapons
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
		weapon.animate_transform(0, false)
	
	#initialize AI component
	if has_node("AI") == true:
		$AI.set_parent(self)
	
	#error: no explosion component
	if has_node("Explosion") == false:
		push_error(name + " has no explosion node. Please attach one.")
	
	#bot physics and properties
	$CollisionShape.shape = CircleShape2D.new()
	$CollisionShape.shape.radius = bot_radius
	$DischargeRadius/CollisionShape2D.shape = CircleShape2D.new()
	$DischargeRadius/CollisionShape2D.shape.radius = 500
	linear_damp = TURRET_MODE_DAMP
	angular_damp = TURRET_MODE_DAMP
	if destructible == false:
		$Bars/Shield.hide()
		$Bars/Health.hide()
	
	#bot's body graphics setup
	$Name/Label.rect_position.y = -bot_radius - 54
	var tex_scale: float = float(bot_radius)/float(DEFAULT_BOT_RADIUS)
	_body_texture.scale = Vector2(tex_scale, tex_scale)
	$Legs/Sprite.scale = Vector2(tex_scale, tex_scale)
	bar_shield.rect_position.y += bot_radius + 15 #-> 15 is hardcoded for now
	bar_health.rect_position.y += bar_shield.rect_position.y + 15
	bar_shield.margin_left = -bot_radius
	bar_shield.margin_right = bot_radius
	bar_health.margin_left = -bot_radius
	bar_health.margin_right = bot_radius
	var bar_scale: float = float(bot_radius*2)/150.0 #-> 150 is the bar length in pixels
	bar_shield.rect_scale.x = bar_scale
	bar_health.rect_scale.x = bar_scale
	var outline = bot_radius + OUTLINE_SIZE
	_body_outline.polygon = _plot_circle_points(outline)
	var cp = _plot_circle_points(bot_radius) #<- circle points
	_body_charge_effect.polygon = cp
	_body_weapon_hatch.polygon = [cp[0], cp[1], cp[2], cp[10], cp[11], cp[12],
		cp[13], cp[14], cp[22], cp[23]]
	_init_legs([cp[4], cp[12], cp[20]])


func _init_legs(circle_points) -> void:
	var leg_sprite: = $Legs/Sprite
	var deg: = 360.0/POLY_SIDES
	for i in circle_points.size():
		var leg_node = get_node("Legs/Leg" + str(i))
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


func _plot_circle_points(radius: int) -> Array:
	var circle_points = []
	for i in range(POLY_SIDES):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*(360.0/POLY_SIDES))))
	return circle_points


#use only for initialization or in bot stations
func reset_bot_vars() -> void:
	if state == State.DEAD:
		return
	
	#for the upcoming core mod implementation be sure to always add mass
	mass = mass * (float(bot_radius)/float(DEFAULT_BOT_RADIUS))
	#makes sure even heavy bots can charge although at a shorter distance
	_charge_commit_velocity = DEFAULT_COMMIT_VELOCITY / mass
	
	current_shield_cap = shield_cap
	set_current_shield(current_shield_cap)
	current_shield_regen = shield_regen
	
	current_health_cap = health_cap
	set_current_health(current_health_cap)
	
	current_transform_speed = transform_speed
	set_current_charge_cooldown(charge_cooldown)
	current_charge_force_mult = charge_force_mult
	current_charge_crit_mult = charge_crit_mult
	current_charge_crit_chance = charge_crit_chance
	current_charge_dmg_rate = charge_dmg_rate
	current_weap_dmg_rate = weap_dmg_rate
	current_speed = speed
	current_dmg_resist = dmg_resist
	current_knockback_resist = knockback_resist
	
	current_faction = faction
	_body_outline.modulate = current_faction
	_body_weapon_hatch.modulate = current_faction
	$Name/Label.set("custom_colors/font_color", current_faction)
	
	for weap in arr_weapons:
		if is_instance_valid(weap) == false:
			continue
		weap.reset_weap_vars()


func _process(delta: float) -> void:
	$Bars.global_rotation = 0
	$Name.global_rotation = 0
	
	#name visibile on hover
	if (state != State.DEAD &&
		global_position.distance_to(get_global_mouse_position()) < bot_radius * 2):
		$Name.visible = true
	else:
		$Name.visible = false
	
	#rolling ball sliding texture
	_apply_rolling_effects(delta)
	
	#reset colors after charging
	_end_charging_effect()


#ccd may be able to prevent wall phasing on fast moving bots
func _physics_process(_delta: float) -> void:
	if continuous_cd == RigidBody2D.CCD_MODE_DISABLED && linear_velocity.length() > 2800:
		continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	elif continuous_cd == RigidBody2D.CCD_MODE_CAST_RAY && linear_velocity.length() <= 2800:
		continuous_cd = RigidBody2D.CCD_MODE_DISABLED


func _integrate_forces(pstate: Physics2DDirectBodyState) -> void:
	#teleport
	if _teleport_pos != null:
		pstate.transform.origin = _teleport_pos
		_teleport_pos = null
	#velocity
	applied_force = Vector2(0,0)
	if state == State.ROLL:
		velocity = velocity.normalized() * current_speed
		pstate.add_central_force(velocity)
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
		_switch_tween.interpolate_property(_body_texture, "texture_offset", _body_texture.texture_offset,
			Vector2(0,0), 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		_switch_tween.start()
		_unrolled = true
	elif _check_if_turret() == false:
		_body_texture.texture_offset -= linear_velocity.rotated(-rotation) * (ROLLING_SPEED * delta)
		_unrolled = false


func _check_if_turret() -> bool:
	match state:
		State.TO_TURRET, State.TURRET, State.WEAP_COMMIT:
			return true
		State.ROLL, State.TO_ROLL:
			return false
		State.DEAD, State.STUN:
			match $StateMachine.before_stun:
				State.TURRET, State.TO_TURRET, State.WEAP_COMMIT:
					return true
				State.TO_ROLL, State.ROLL:
					return false
	return false


func switch_mode():
	if state == State.ROLL || state == State.TURRET:
		$StateMachine.switching = true


#state machine exclusive func
func switch_to_turret() -> void:
	velocity = Vector2(0,0)
	$Sounds/ChangeMode.play()
	linear_damp = TURRET_MODE_DAMP
	angular_damp = TURRET_MODE_DAMP
	mode = RigidBody2D.MODE_CHARACTER
	_animate_legs_to_turret()
	_animate_weapon_hatch_to_turret()


func _animate_legs_to_turret() -> void:
	for leg in _legs_position.keys():
		leg.visible = true
		_switch_tween.interpolate_property(leg, 'position', Vector2(0,0), _legs_position[leg],
			current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func _animate_weapon_hatch_to_turret() -> void:
	if is_instance_valid(current_weapon) == true:
		_body_weapon_hatch.global_rotation = current_weapon.global_rotation
		current_weapon.animate_transform(current_transform_speed, true)
	_body_weapon_hatch.show()
	_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
		current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


#state machine exclusive func
func switch_to_roll() -> void:
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
	if is_instance_valid(current_weapon) == true:
		current_weapon.global_rotation = _body_weapon_hatch.global_rotation
		current_weapon.animate_transform(current_transform_speed, false)
	_switch_tween.interpolate_property(_body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
		current_transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func _on_SwitchTween_tween_all_completed() -> void:
	if state == State.TO_ROLL:
		_body_weapon_hatch.hide()
		for leg in _legs_position.keys():
			leg.visible = false
	$StateMachine.switching = false


func shoot_weapon() -> void:
	if state == State.TURRET:
		current_weapon.fire()


#some weapon have longer deploy animation -- will use shoot_commit var
func change_weapon(slot_num: int) -> bool:
	var weap = arr_weapons[slot_num]
	if is_instance_valid(weap) == false:
		return false
	match state:
		State.TO_ROLL, State.TO_TURRET, State.STUN, State.WEAP_COMMIT, State.DEAD:
			return false
	current_weapon.modulate = Color(1,1,1,0)
	match state:
		State.TURRET:
			current_weapon = weap
			current_weapon.modulate = Color(1,1,1,1)
		State.ROLL, State.CHARGE_ROLL:
			current_weapon = weap
	return true


#charge strength depends on speed and force multiplier
func charge_roll(charge_direction: float) -> void:
	if state == State.ROLL && is_charge_roll_ready() == true:
		$StateMachine.charge_dir = charge_direction
		apply_central_impulse(Vector2(current_speed,0).rotated($StateMachine.charge_dir) *
			current_charge_force_mult)
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
		_body_charge_effect.visible = true


func _on_ChargeTrail_timeout() -> void:
	_play_anim(global_position, _body_charge_effect.duplicate(), "trail")


func _end_charging_effect() -> void:
	#stun state is included because of discharge parry/stun eventually
	match state:
		State.CHARGE_ROLL, State.DEAD, State.STUN:
			if linear_velocity.length() <= current_speed * _charge_commit_velocity:
				_body_outline.modulate = current_faction
				_body_charge_effect.modulate.a = 0
				_body_charge_effect.visible = false
				$Timers/ChargeTrail.stop()
				$StateMachine.charge_dir = null


#coroutine resume signal
signal resumed


func _on_Resume_timeout() -> void:
	emit_signal("resumed")


var _teleport_pos = null


func teleport(to_position: Vector2) -> void:
	_teleport_pos = to_position
	$Sounds/Teleport.play()


func apply_knockback(knockback: Vector2) -> void:
	apply_central_impulse(knockback - (knockback*current_knockback_resist))


func take_damage(damage: float, knockback: Vector2, disp: bool = true) -> void:
	apply_knockback(knockback)
	var real_dmg = damage - (damage * current_dmg_resist)
	if disp == true:
		dmg_effect(real_dmg)
	if destructible == false:
		$Sounds/ShieldDamage.play()
		return
	if state == State.DEAD:
		return
	if current_shield - real_dmg >= 0:
		$Sounds/ShieldDamage.play()
		current_shield -= real_dmg
	elif current_shield - real_dmg < 0:
		$Sounds/HealthDamage.play()
		current_health += current_shield - real_dmg
		current_shield = 0
	if disp == false:
		$Sounds/ShieldDamage.stop()
		$Sounds/HealthDamage.stop()
	bar_shield.value = current_shield
	bar_health.value = current_health


func discharge_parry() -> void:
	match state:
		State.TURRET, State.TO_TURRET, State.WEAP_COMMIT, State.TO_ROLL:
			if _timer_charge_cooldown.is_stopped() == true:	
				_clear_surrounding_proj()
				if _body_charge_effect.get_node("Anim").is_playing() == false:
					_body_charge_effect.get_node("Anim").play("discharge_parry")
				$Sounds/DischargeParry.play()
				timer_discharge_parry.start()
				_timer_charge_cooldown.start()


func _clear_surrounding_proj() -> void:
	var areas: Array = $DischargeRadius.get_overlapping_areas()
	for area in areas:
		if current_faction == area.shooter_faction():
			continue
		if area.has_node("Explosion") == true:
			area.get_node("Explosion").exploded = true
		area.stop_projectile()


func _on_Bot_body_entered(body: Node) -> void:
	if state != State.CHARGE_ROLL:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	emit_spark(body.position)
	$Sounds/ChargeAttackHit.play()
	var damage: float = ((current_speed * 0.125 * current_charge_force_mult) *
		current_charge_dmg_rate)
	#apply crit dmg
	if rand_range(0, 1.0) <= current_charge_crit_chance:
		damage *= current_charge_crit_mult
		if body is Global.CLASS_BOT && current_faction != body.current_faction:
			body.crit_effect()
	if body is Global.CLASS_BOT:
		if current_faction == body.current_faction:
			return
		#if both bots are charging each other
		#or a charging bot hit a parrying bot, damage is reduced to 1%
		if body.state == Global.CLASS_BOT.State.CHARGE_ROLL:
			deflect_effect()
			return
		elif body.timer_discharge_parry.is_stopped() == false:
			var dir: float = (global_position - body.global_position).angle()
			apply_knockback(Vector2(1500, 0).rotated(dir))
			deflect_effect()
			return
	body.take_damage(damage, Vector2(0,0))


func emit_spark(pos: Vector2) -> void:
	var final_pos = (position - pos).normalized() * bot_radius
	$CollisionSpark.position = final_pos
	$CollisionSpark.emitting = true


var _crit_feedback = preload("res://scenes/global/feedback/Critical.tscn")
var _stun_feedback = preload("res://scenes/global/feedback/Stun.tscn")
var _deflect_feedback = preload("res://scenes/global/feedback/Deflect.tscn")
var _dmg_feedback = preload("res://scenes/global/feedback/Damage.tscn")


func _play_anim(pos: Vector2, anim_instance: Node, anim_name: String) -> void:
	_level_node.add_child(anim_instance)
	var anim = anim_instance.get_node("Anim")
	anim_instance.global_position = pos
	anim.connect("animation_finished", _level_node, "_on_Anim_finished",
		[anim_instance])
	anim.play(anim_name)


func stun_effect(stun_timer: float) -> void:
	timer_stun.start(stun_timer)
	_play_anim(global_position, _stun_feedback.instance(), "stun")


func crit_effect() -> void:
	_play_anim(global_position, _crit_feedback.instance(), "critical")


func dmg_effect(damage: float) -> void:
	var anim = _dmg_feedback.instance()
	var anim_txt = anim.get_node("Label")
	anim_txt.text = str(round(damage))
	_play_anim(global_position, anim, "dmg")


func deflect_effect() -> void:
	_play_anim(global_position, _deflect_feedback.instance(), "deflect")


func _on_ShieldRecoveryTimer_timeout() -> void: #<- rate 1sec/4
	if current_shield_regen <= 0 || current_shield_cap <= 0:
		return
	if current_shield + current_shield_regen * 0.25 > current_shield_cap:
		current_shield = current_shield_cap
	elif current_shield + current_shield_regen * 0.25 <= current_shield_cap:
		current_shield += current_shield_regen * 0.25
	bar_shield.value = current_shield


signal dead


func explode() -> void:
	emit_signal("dead")
	var color = Color(0.18, 0.18, 0.18)
	$Legs.modulate = color
	$Body.modulate = color
	$Bars.hide()
	$Timers/ExplodeDelay.start()
	if is_instance_valid(_level_node.get_player()) == true:
		$Explosion.set_player_cam(_level_node.get_player().get_node("Camera2D"))


func _on_ExplodeDelay_timeout() -> void:
	$CollisionShape.disabled = true
	if is_instance_valid(current_weapon) == true:
		current_weapon.modulate.a = 0
	$Legs.hide()
	$Body.hide()
	mode = RigidBody2D.MODE_STATIC
	#explosion effects here
	$Explosion/Blast/Anim.connect("animation_finished", self, "_on_Explode_finished")
	$Explosion.start_explosion()


func _on_Explode_finished(_anim_name: String) -> void:
	queue_free()

