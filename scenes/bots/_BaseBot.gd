extends RigidBody2D

#default bot values
export (int) var shield_capacity = 100
export (int) var health_capacity = 100
export (int) var roll_speed = 1500
export (bool) var is_destructible = true
export (bool) var is_hostile = true
export (int) var bot_radius = 32
const DEFAULT_BOT_RADIUS = 32
const CHARGE_FORCE_FACTOR: float = 0.6
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.7
const NO_EFFECT_VELOCITY_FACTOR: float = 0.65
const OUTLINE_SIZE: float = 3.0
const CONTROL_VELOCITY_FACTOR: float = 0.6
const ROLLING_EFFECT_FACTOR: float = 15.0
const ROLL_MODE_DAMP: int = 2
const SHOOT_MODE_DAMP: int = 5
const TRANSFORM_ANIM_SPEED: float = 0.2
onready var control_velocity: int = roll_speed * CONTROL_VELOCITY_FACTOR
onready var roll_mode: bool = false
var legs_position = {}
var charging: bool = false
var charge_damage: int = 20
var shield_recovery: int = 3 #(2 * shield_recovery) per second -> update is 0.5 sec
var velocity: Vector2
var in_control: bool = true
var current_shield: int
var current_health: int
var current_roll_speed: int
signal shooting


func _ready() -> void:
	set_up_body_graphics()
	set_up_properties()


func _physics_process(delta: float) -> void:
	#charge roll graphical feedback/effects
	apply_charge_effects()
	
	#keeps shield and health bars in place
	$Bars.global_rotation = 0
	
	#rolling ball graphical effect
	#bodytexture size must be the same as bot's rect size(radius*2 by radius*2)
	#because texture offset resets based on radius
	apply_rolling_effects()
	
	#high speed means temporarily losing control
	#makes charge roll an attack commitment, as a result it
	#becomes a high risk high reward move
	check_if_in_control()
	if in_control == false:
		$Weapon.look_at(Vector2(1,0))
		return
	
	#velocity calculations
	_control()
	apply_force(delta)


func _control() -> void:
	pass


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass


onready var body_outline = $Body/Outline
onready var body_texture = $Body/Texture
onready var body_charge_effect = $Body/ChargeEffect
func set_up_body_graphics() -> void:
	$Bars.position.y += bot_radius - DEFAULT_BOT_RADIUS
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


func plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(24):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*15.0)))
	return circle_points


onready var shield_bar = $Bars/Shield
onready var health_bar = $Bars/Health
func set_up_properties() -> void:
	$CollisionShape.shape.radius = bot_radius
	linear_damp = SHOOT_MODE_DAMP
	if is_destructible == false:
		$Bars.hide()
	current_shield = shield_capacity
	current_health = health_capacity
	shield_bar.max_value = shield_capacity
	shield_bar.value = current_shield
	health_bar.max_value = health_capacity
	health_bar.value = current_health
	current_roll_speed = roll_speed


func apply_charge_effects() -> void:
	if linear_velocity.length() > current_roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR && $ChargeCooldown.is_stopped() == false:
		body_outline.color = Color(0.917647, 0, 0.752941)
		body_charge_effect.color.a = 255
		charging = true
	elif linear_velocity.length() < current_roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		body_outline.color = lerp(body_outline.color, Color(1,1,1), 0.8)
		body_charge_effect.color.a = lerp(body_charge_effect.color.a, 0, 0.8)
		charging = false


#still looks flat, "bulge" texture effect shader??..
func apply_rolling_effects() -> void:
	if roll_mode == false:
		body_texture.texture_offset = lerp(body_texture.texture_offset, Vector2(0,0), 0.5)
		return
	if roll_mode == true:
		body_texture.texture_offset -= (linear_velocity.rotated(-rotation)/current_roll_speed) * ROLLING_EFFECT_FACTOR
	if body_texture.texture_offset.x < -bot_radius*2 || body_texture.texture_offset.x > bot_radius*2:
		body_texture.texture_offset.x = 0
	if body_texture.texture_offset.y < -bot_radius*2 || body_texture.texture_offset.y > bot_radius*2:
		body_texture.texture_offset.y = 0
	if body_texture.texture_rotation < -360 || body_texture.texture_rotation > 360:
		body_texture.texture_rotation = 0


func check_if_in_control() -> void:
	if linear_velocity.length() < control_velocity:
		in_control = true
	else:
		in_control = false


func apply_force(delta) -> void:
	if roll_mode == true:
		velocity = velocity * delta
		velocity = velocity.normalized() * current_roll_speed
	applied_force = velocity


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
	in_control = false
	var leg_tween = $Legs/LegTween
	if roll_mode == true:
		for leg in legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', leg.position, Vector2(0,0),
				TRANSFORM_ANIM_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()
	if roll_mode == false:
		for leg in legs_position.keys():
			leg_tween.interpolate_property(leg, 'position', Vector2(0,0), legs_position[leg],
				TRANSFORM_ANIM_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			leg_tween.start()


func _on_LegTween_tween_all_completed() -> void:
	in_control = true


func animate_weapon_hatch() -> void:
	in_control = false
	var weapon_hatch_animation = $WeaponHatch/WeaponHatchAnimationPlayer
	if roll_mode == true:
		weapon_hatch_animation.play("change_mode")
	if roll_mode == false:
		weapon_hatch_animation.play_backwards("change_mode")


func _on_WeaponHatchAnimationPlayer_animation_finished(anim_name: String) -> void:
	if roll_mode == true:
		$Weapon.hide()
	if roll_mode == false:
		$Weapon.show()
	in_control = true


func shoot_weapon() -> void:
	if $Weapon/Cooldown.is_stopped() == false || $Weapon/OverheatCooldown.is_stopped() == false || roll_mode == true:
		return
	emit_signal("shooting", $Weapon.get_projectile(),
		$Weapon/Muzzle.global_position, $Weapon/Muzzle.global_rotation, is_hostile)


func charge_attack(charge_direction) -> void:
	if $ChargeCooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(Vector2(current_roll_speed,0).rotated(charge_direction) * CHARGE_FORCE_FACTOR)
	$ChargeCooldown.start()


func take_damage(damage) -> void:
	if is_destructible == false:
		return
	if current_shield - damage >= 0:
		current_shield -= damage
		shield_bar.value = current_shield
	elif current_shield - damage < 0:
		current_health += current_shield - damage
		current_shield = 0
		shield_bar.value = current_shield
		health_bar.value = current_health
	if current_health <= 0:
		queue_free()


func _on_Bot_body_entered(body: Node) -> void:
	if charging == true && body.get_parent().name == "Bots" && is_hostile != body.is_hostile:
		body.take_damage(charge_damage)
	elif charging == true:
		body.take_damage(charge_damage)


func _on_ShieldRecoveryTimer_timeout() -> void:
	if current_shield + shield_recovery > shield_capacity:
		current_shield = shield_capacity
	elif current_shield + shield_recovery <= shield_capacity:
		current_shield += shield_recovery
	shield_bar.value = current_shield
