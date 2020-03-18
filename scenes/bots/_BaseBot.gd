extends RigidBody2D

#default bot values
export (int) var shield_capacity: = 20
export (int) var health_capacity: = 20
export (int) var roll_speed: = 1300 #absolute max 2500
export (bool) var is_destructible: = true
export (bool) var is_hostile: = true #projectiles pass through and charge has no effect on bot with same bool value
export (int) var bot_radius: = 32
export (int) var shield_recovery_per_second: = 2 #absolute min is 2, no recovery if less than 2
export (float) var transform_speed: = 0.6 #absolute min is 0.1, recommended max is 0.6
export (float) var charge_cooldown: = 2.5 #absolute min is 0.5, recommended max is 2.5
export (float) var knockback_resist: = 0.25 #absolute max is 1.0
export (float) var charge_force_factor: = 0.5 #absolute max is 1.0
const BARS_OFFSET: int = 15
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.65
const NO_EFFECT_VELOCITY_FACTOR: float = 0.6
const OUTLINE_SIZE: float = 4.0
const ROLLING_EFFECT_FACTOR: float = 0.01
const ROLL_MODE_DAMP: int = 2
const SHOOT_MODE_DAMP: int = 5
const CHARGE_DAMAGE_FACTOR: float = 0.03
var legs_position: Dictionary = {}
var velocity: Vector2
var current_shield: int
var current_health: int
var current_roll_speed: int
var is_alive: bool = true
var is_charging: bool = false
var is_transforming: bool = false
signal shooting


onready var roll_mode: bool = false
onready var body_outline = $Body/Outline
onready var body_texture = $Body/Texture
onready var body_charge_effect = $Body/ChargeEffect
onready var shield_bar = $Bars/Shield
onready var health_bar = $Bars/Health
onready var body_weapon_hatch = $Body/WeaponHatch


func _ready() -> void:
	#never changing stuff
	set_up_constant_vars()
	
	#might change on the course of the game
	update_vars()


func set_up_constant_vars() -> void:
	$CollisionShape.shape.radius = bot_radius
	linear_damp = SHOOT_MODE_DAMP
	if is_destructible == false:
		$Bars.hide()
	
	#bot's body set up
	shield_bar.rect_position.y += bot_radius + BARS_OFFSET
	health_bar.rect_position.y += shield_bar.rect_position.y + BARS_OFFSET
	var circle_points = plot_circle_points(bot_radius)
	body_texture.polygon = circle_points
	body_texture.position = Vector2(-bot_radius, -bot_radius)
	body_texture.offset = Vector2(bot_radius, bot_radius)
	body_charge_effect.polygon = circle_points
	body_charge_effect.position = Vector2(-bot_radius, -bot_radius)
	body_charge_effect.offset = Vector2(bot_radius, bot_radius)
	var outline = bot_radius + OUTLINE_SIZE
	body_outline.polygon = plot_circle_points(outline)
	body_outline.position = Vector2(-outline, -outline)
	body_outline.offset = Vector2(outline, outline)
	set_up_legs([circle_points[4], circle_points[12], circle_points[20]])
	set_up_hatch(circle_points)


func set_up_legs(points) -> void:
	var leg_sprite = $Legs/Sprite
	var leg1 = $Legs/Leg1
	var leg2 = $Legs/Leg2
	var leg3 = $Legs/Leg3
	for i in points.size():
		var leg = leg_sprite.duplicate(DUPLICATE_USE_INSTANCING)
		match i:
			0:
				leg1.add_child(leg)
				leg1.position = points[0]
				legs_position[leg1] = points[0]
				leg1.rotation = deg2rad(15*4) #<-- 15 degrees times index from circle_points[index]
			1:
				leg2.add_child(leg)
				leg2.position = points[1]
				legs_position[leg2] = points[1]
				leg2.rotation = deg2rad(15*12)
			2:
				leg3.add_child(leg)
				leg3.position = points[2]
				legs_position[leg3] = points[2]
				leg3.rotation = deg2rad(15*20)
	leg_sprite.hide()


func set_up_hatch(circle_points: Array) -> void:
	body_weapon_hatch.polygon[0] = circle_points[0]
	body_weapon_hatch.polygon[1] = circle_points[1]
	body_weapon_hatch.polygon[2] = circle_points[2]
	body_weapon_hatch.polygon[3] = circle_points[10]
	body_weapon_hatch.polygon[4] = circle_points[11]
	body_weapon_hatch.polygon[5] = circle_points[12]
	body_weapon_hatch.polygon[6] = circle_points[13]
	body_weapon_hatch.polygon[7] = circle_points[14]
	body_weapon_hatch.polygon[8] = circle_points[22]
	body_weapon_hatch.polygon[9] = circle_points[23]


func plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(24):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*15.0)))
	return circle_points


func update_vars() -> void:
	check_for_capped_vars()
	current_shield = shield_capacity
	current_health = health_capacity
	current_roll_speed = roll_speed
	shield_bar.max_value = shield_capacity
	shield_bar.value = current_shield
	health_bar.max_value = health_capacity
	health_bar.value = current_health
	$ChargeCooldown.wait_time = charge_cooldown


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


func _physics_process(delta: float) -> void:
	#charge roll graphical feedback/effects
	apply_charging_effects()
	
	#keeps shield and health bars in place
	$Bars.global_rotation = 0
	
	#rolling ball graphical effect
	#bodytexture size must be the same as bot's rect size(radius*2 by radius*2)
	#because texture offset resets based on radius
	apply_rolling_effects()
	
	#high speed means temporarily losing control
	#makes charge roll an attack commitment, as a result it
	#becomes a high risk high reward move
	if check_if_in_control() == false:
		return
	
	#velocity calculations
	_control(delta)
	apply_force(delta)


func _control(delta) -> void:
	pass


#?? if i should put this on integrate_forces func??
func apply_force(delta) -> void:
	if roll_mode == true:
		velocity = (velocity*delta).normalized() * current_roll_speed
	applied_force = velocity


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass


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


#looks flat on bigger radius, trying to figure out how to implement "bulge" texture effect shader
func apply_rolling_effects() -> void:
	if roll_mode == false:
		body_texture.texture_offset = lerp(body_texture.texture_offset, Vector2(0,0), 0.5)
		return
	if roll_mode == true:
		body_texture.texture_offset -= (linear_velocity.rotated(-rotation)/current_roll_speed) * (current_roll_speed * ROLLING_EFFECT_FACTOR)
	if body_texture.texture_offset.x < -bot_radius*2 || body_texture.texture_offset.x > bot_radius*2:
		body_texture.texture_offset.x = 0
	if body_texture.texture_offset.y < -bot_radius*2 || body_texture.texture_offset.y > bot_radius*2:
		body_texture.texture_offset.y = 0
	if body_texture.texture_rotation < -360 || body_texture.texture_rotation > 360:
		body_texture.texture_rotation = 0


func check_if_in_control() -> bool:
	if is_alive == true && is_charging == false && is_transforming == false:
		return true
	else:
		return false


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
	if $ChargeCooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(Vector2(current_roll_speed,0).rotated(charge_direction) * charge_force_factor)
	$ChargeCooldown.start()


func take_damage(damage, knockback) -> void:
	apply_central_impulse(knockback - (knockback*knockback_resist))
	if is_destructible == false:
		return
	if current_shield - damage >= 0:
		current_shield -= damage
	elif current_shield - damage < 0:
		current_health += current_shield - damage
		current_shield = 0
	shield_bar.value = current_shield
	health_bar.value = current_health
	if current_health <= 0:
		explode()


func explode() -> void:
	is_alive = false
	$Legs.modulate = Color(0.180392, 0.180392, 0.180392)
	$Body.modulate = Color(0.180392, 0.180392, 0.180392)
	$Bars.hide()
	if has_node("PlayerBars") == true:
		$PlayerBars.hide()
	$ExplodeDelay.start()


func _on_ExplodeDelay_timeout() -> void:
	$Legs.hide()
	$Body.hide()
	$Bars.hide()
	$Weapon.hide()
	$CollisionShape.disabled = true
	$ExplosionParticles.emitting = true
	$ExplodeTimer.start()


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
	shield_bar.value = current_shield
