extends RigidBody2D

#make sure to reimport texture as repeating

export var bot_radius: float = 32.0
export var shield_capacity: int = 20
export var health_capacity: int = 20
export var roll_speed: int = 1200 #absolute max 2500
export var is_destructible: bool = true
export var is_hostile: bool = true #projectiles pass through and charge has no effect on bot with same bool value
export var shield_recovery_per_second: int = 2 #absolute min is 2, no recovery if less than 2
export var transform_speed: float = 0.6 #absolute min is 0.1, recommended max is 0.6
export var charge_cooldown: float = 2.5 #absolute min is 0.5, recommended max is 2.5
export var knockback_resist: float = 0.1 #absolute max is 1.0
export var charge_force_factor: float = 0.5 #absolute max is 1.0
const DEFAULT_BOT_RADIUS: float = 32.0
const BARS_OFFSET: int = 15
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.65
const NO_EFFECT_VELOCITY_FACTOR: float = 0.6
const OUTLINE_SIZE: float = 4.0
const ROLLING_EFFECT_FACTOR: float = 0.01
const ROLL_MODE_DAMP: int = 2
const SHOOT_MODE_DAMP: int = 5
const CHARGE_DAMAGE_FACTOR: float = 0.03
const POLYGON_SIDES: int = 24
var legs_position: Dictionary = {}
var velocity: Vector2
var current_shield: int
var current_health: int
var current_roll_speed: int
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
	set_up_constant_vars()
	
	#might change on the course of the game
	update_vars()


func set_up_constant_vars() -> void:
	linear_damp = SHOOT_MODE_DAMP
	if is_destructible == false:
		$Bars.hide()
	
	#bot's body set up
	body_texture.scale = Vector2(bot_radius/DEFAULT_BOT_RADIUS, bot_radius/DEFAULT_BOT_RADIUS)
	body_texture.position = Vector2(-bot_radius, -bot_radius)
	bar_shield.rect_position.y += bot_radius + BARS_OFFSET
	bar_health.rect_position.y += bar_shield.rect_position.y + BARS_OFFSET
	var circle_points = plot_circle_points(bot_radius)
	body_charge_effect.polygon = circle_points
	body_charge_effect.position = Vector2(-bot_radius, -bot_radius)
	body_charge_effect.offset = Vector2(bot_radius, bot_radius)
	var outline = bot_radius + OUTLINE_SIZE
	body_outline.polygon = plot_circle_points(outline)
	body_outline.position = Vector2(-outline, -outline)
	body_outline.offset = Vector2(outline, outline)
	
	#other set ups
	set_up_legs([circle_points[4], circle_points[12], circle_points[20]])
	set_up_hatch([circle_points[0], circle_points[1], circle_points[2], circle_points[10],
		circle_points[11], circle_points[12], circle_points[13], circle_points[14],
		circle_points[22], circle_points[23]])


func set_up_legs(circle_points) -> void:
	var leg_sprite = $Legs/Sprite
	var leg1 = $Legs/Leg1
	var leg2 = $Legs/Leg2
	var leg3 = $Legs/Leg3
	var deg = 360/POLYGON_SIDES
	for i in circle_points.size():
		var leg = leg_sprite.duplicate(DUPLICATE_USE_INSTANCING)
		match i:
			0:
				leg1.add_child(leg)
				leg1.position = circle_points[0]
				legs_position[leg1] = circle_points[0]
				leg1.rotation = deg2rad(4*deg) #<-- circle degrees * index from circle_points[index]
			1:
				leg2.add_child(leg)
				leg2.position = circle_points[1]
				legs_position[leg2] = circle_points[1]
				leg2.rotation = deg2rad(12*deg)
			2:
				leg3.add_child(leg)
				leg3.position = circle_points[2]
				legs_position[leg3] = circle_points[2]
				leg3.rotation = deg2rad(20*deg)
	leg_sprite.hide()


func set_up_hatch(circle_points: Array) -> void:
	body_weapon_hatch.polygon = circle_points


func plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(POLYGON_SIDES):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*(360/POLYGON_SIDES))))
	return circle_points


func update_vars() -> void:
	check_for_capped_vars()
	$CollisionShape.shape.radius = bot_radius
	current_shield = shield_capacity
	current_health = health_capacity
	current_roll_speed = roll_speed
	bar_shield.max_value = shield_capacity
	bar_shield.value = current_shield
	bar_health.max_value = health_capacity
	bar_health.value = current_health
	timer_charge_cooldown.wait_time = charge_cooldown


func check_for_capped_vars() -> void:
	if roll_speed > 2500:
		roll_speed = 2500
	if shield_recovery_per_second < 2.0:
		shield_recovery_per_second = 2.0
	if transform_speed < 0.1:
		transform_speed = 0.1
	if charge_force_factor > 1.0:
		charge_force_factor = 1.0
	if charge_cooldown < 0.5:
		charge_cooldown = 0.5
	if knockback_resist > 1.0:
		knockback_resist = 1.0


func _process(delta: float) -> void:
	#keeps shield and health bars in place
	$Bars.global_rotation = 0
	
	#high speed, transforming, and dying means losing control
	#makes charge roll an attack commitment
	check_if_in_control()
	
	#velocity calculations
	if is_in_control == true:
		_control(delta)


#capped to 60 fps
func _physics_process(delta: float) -> void:
	#charge roll graphical feedback/effects
	apply_charging_effects()
	
	#rolling ball graphical effect
	#bodytexture size must be the same as bot's rect size(radius*2 by radius*2)
	#because texture offset resets based on radius
	apply_rolling_effects()


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	apply_force()


func _control(delta) -> void:
	pass


func apply_force() -> void:
	if roll_mode == true:
		velocity = velocity.normalized() * current_roll_speed
	applied_force = velocity


func apply_charging_effects() -> void:
	var hostile = Color(0.941406, 0.172836, 0.172836)
	var non_hostile = Color(0.223529, 0.956863, 0.25098)
	if linear_velocity.length() <= current_roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		#outline for hostiles becomes red
		if is_hostile == true:
			body_outline.color = lerp(body_outline.color, hostile, 0.8)
		#outline for non-hostiles becomes green
		elif is_hostile == false:
			body_outline.color = lerp(body_outline.color, non_hostile, 0.8)
		body_charge_effect.color.a = lerp(body_charge_effect.color.a, 0, 0.8)
		body_weapon_hatch.color = body_outline.color
		is_charging = false
	elif linear_velocity.length() > current_roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR:
		body_outline.color = Color(1, 0.2, 0.839216)
		body_charge_effect.color.a = 255
		is_charging = true


func apply_rolling_effects() -> void:
	if roll_mode == false:
		body_texture.texture_offset = lerp(body_texture.texture_offset, Vector2(0,0), 0.5)
		return
	if roll_mode == true:
		body_texture.texture_offset -= (linear_velocity.rotated(-rotation)/current_roll_speed) * (current_roll_speed * ROLLING_EFFECT_FACTOR)


func check_if_in_control() -> void:
	if is_alive == true && is_charging == false && is_transforming == false:
		is_in_control = true
	else:
		is_in_control = false


func switch_mode() -> void:
	roll_mode = !roll_mode
	animate_legs()
	animate_weapon_hatch()
	if roll_mode == true:
		linear_damp = ROLL_MODE_DAMP
		mode = RigidBody2D.MODE_RIGID
	elif roll_mode == false:
		linear_damp = SHOOT_MODE_DAMP
		mode = RigidBody2D.MODE_CHARACTER


func animate_legs() -> void:
	is_transforming = true
	var leg_tween = $Legs/LegTween
	if roll_mode == true:
		for leg in legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
				transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()
	elif roll_mode == false:
		for leg in legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', Vector2(0,0), legs_position[leg],
				transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()


func _on_LegTween_tween_all_completed() -> void:
	is_transforming = false


func animate_weapon_hatch() -> void:
	is_transforming = true
	var weapon_hatch_tween = body_weapon_hatch.get_node("WeaponHatchTween")
	var weapon_anim = $Weapon/AnimationPlayer
	if roll_mode == true:
		weapon_hatch_tween.interpolate_property(body_weapon_hatch, 'scale', Vector2(1,1), Vector2(1,0),
			transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Weapon.global_rotation = body_weapon_hatch.global_rotation
		weapon_anim.play("change_mode")
	elif roll_mode == false:
		body_weapon_hatch.global_rotation = $Weapon.global_rotation
		body_weapon_hatch.show()
		$Weapon.show()
		weapon_hatch_tween.interpolate_property(body_weapon_hatch, 'scale', Vector2(1,0), Vector2(1,1),
			transform_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		weapon_anim.play_backwards("change_mode")
	weapon_hatch_tween.start()


func _on_WeaponHatchTween_tween_all_completed() -> void:
	if roll_mode == true:
		body_weapon_hatch.hide()
		$Weapon.hide()
	is_transforming = false


func shoot_weapon() -> void:
	if $Weapon/Cooldown.is_stopped() == false || $Weapon/OverheatCooldown.is_stopped() == false || roll_mode == true:
		return
	emit_signal("shooting", $Weapon.get_projectile(),
		$Weapon/Muzzle.global_position, $Weapon/Muzzle.global_rotation, is_hostile)


func charge_attack(charge_direction) -> void:
	if timer_charge_cooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(Vector2(current_roll_speed,0).rotated(charge_direction) * charge_force_factor)
	timer_charge_cooldown.start()


func take_damage(damage, knockback) -> void:
	apply_central_impulse(knockback - (knockback*knockback_resist))
	if is_destructible == false:
		return
	if current_shield - damage >= 0:
		current_shield -= damage
	elif current_shield - damage < 0:
		current_health += current_shield - damage
		current_shield = 0
	bar_shield.value = current_shield
	bar_health.value = current_health
	if current_health <= 0:
		explode()


func explode() -> void:
	is_alive = !is_alive
	$Legs.modulate = Color(0.180392, 0.180392, 0.180392)
	$Body.modulate = Color(0.180392, 0.180392, 0.180392)
	$Bars.hide()
	if has_node("PlayerBars") == true:
		$PlayerBars.hide()
	$Timers/ExplodeDelay.start()


func _on_ExplodeDelay_timeout() -> void:
	$Legs.hide()
	$Body.hide()
	$Bars.hide()
	$Weapon.hide()
	$CollisionShape.disabled = true
	
	#explosion graphics here
	$ExplosionParticles.emitting = true
	$Timers/ExplodeTimer.start()


func _on_ExplodeTimer_timeout() -> void:
	queue_free()


func _on_Bot_body_entered(body: Node) -> void:
	if is_charging == false:
		return
	var damage = roll_speed * CHARGE_DAMAGE_FACTOR
	if body.get_parent().name == "Bots" && is_hostile == body.is_hostile:
		return
	elif body.get_parent().name == "Bots" && is_hostile != body.is_hostile:
		body.take_damage(damage * charge_force_factor, Vector2(0,0))
	else:
		body.take_damage(damage * charge_force_factor, Vector2(0,0))


func _on_ShieldRecoveryTimer_timeout() -> void:
	if current_shield + shield_recovery_per_second/2 > shield_capacity:
		current_shield = shield_capacity
	elif current_shield + shield_recovery_per_second/2 <= shield_capacity:
		current_shield += shield_recovery_per_second/2
	bar_shield.value = current_shield
