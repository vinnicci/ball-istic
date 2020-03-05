extends RigidBody2D

#eventually ??
#animation states

#default bot values
export (int) var shield_capacity = 1000
export (int) var health_capacity = 500
export (int) var roll_speed = 1500
export (bool) var destructible = true
export (bool) var hostile = true
export (int) var bot_radius = 25
const CRAWL_SPEED: int = 1000
const CHARGE_FORCE_FACTOR: float = 0.6
const CHARGE_EFFECT_VELOCITY_FACTOR: float = 0.76
const NO_EFFECT_VELOCITY_FACTOR: float = 0.7
const CHARGE_GLOW_SIZE: float = 3.0
const CONTROL_VELOCITY_FACTOR: float = 0.6
const ROLLING_EFFECT_FACTOR: float = 15.0
const ROLL_MODE_DAMP: int = 2
const CRAWL_MODE_DAMP: int = 5
var control_velocity: int
var roll_mode: bool = false
var charge_direction: float
var velocity: Vector2
signal shoot


func _ready() -> void:
	#body set up
	set_up_effects()
	
	#physics set up
	set_up_bot_physics()


func _physics_process(delta: float) -> void:
	#charge sprite effects
	check_for_charge_sprite_effects()
	
	#rolling sprite effect
	#bodytexture size must be the same as bot's rect size(radius*2 x radius*2) for this to work
	apply_rolling_effects()
	
	#bot loses control when it's more than control_velocity
	if check_if_in_control() == false:
		return
	
	#velocity calculations
	_control()
	apply_force(delta)


func _control():
	pass


func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass


func set_up_effects() -> void:
	var circle_points = plot_circle_points(bot_radius)
	$BodyTexture.polygon = circle_points
	$BodyTexture.position = Vector2(-bot_radius, -bot_radius)
	$BodyTexture.offset = Vector2(bot_radius, bot_radius)
	$ChargeEffectBody.polygon = circle_points
	$ChargeEffectBody.position = Vector2(-bot_radius, -bot_radius)
	$ChargeEffectBody.offset = Vector2(bot_radius, bot_radius)
	var charge_effect_circle = bot_radius + CHARGE_GLOW_SIZE
	$ChargeEffectGlow.polygon = plot_circle_points(charge_effect_circle)
	$ChargeEffectGlow.position = Vector2(-charge_effect_circle, -charge_effect_circle)
	$ChargeEffectGlow.offset = Vector2(charge_effect_circle, charge_effect_circle)
	$ChargeEffectBody.color.a = 0
	$ChargeEffectGlow.color.a = 0


func plot_circle_points(radius) -> Array:
	var circle_points = []
	for i in range(24):
		circle_points.append(Vector2(radius,0).rotated(deg2rad(i*15.0)))
	return circle_points


func set_up_bot_physics() -> void:
	$BodyCollisionShape.shape.radius = bot_radius
	linear_damp = CRAWL_MODE_DAMP
	control_velocity = roll_speed * CONTROL_VELOCITY_FACTOR


func check_for_charge_sprite_effects() -> void:
	if linear_velocity.length() > roll_speed * CHARGE_EFFECT_VELOCITY_FACTOR && $ChargeCooldown.is_stopped() == false:
		$ChargeEffectGlow.color.a = 255
		$ChargeEffectBody.color.a = 255
	if linear_velocity.length() < roll_speed * NO_EFFECT_VELOCITY_FACTOR:
		$ChargeEffectGlow.color.a = lerp($ChargeEffectGlow.color.a, 0, 0.3)
		$ChargeEffectBody.color.a = lerp($ChargeEffectBody.color.a, 0, 0.3)


func apply_rolling_effects() -> void:
	if $BodyTexture.texture_offset.x < -bot_radius*2 || $BodyTexture.texture_offset.x > bot_radius*2:
		$BodyTexture.texture_offset.x = 0
	if $BodyTexture.texture_offset.y < -bot_radius*2 || $BodyTexture.texture_offset.y > bot_radius*2:
		$BodyTexture.texture_offset.y = 0
	if roll_mode == true:
		$BodyTexture.texture_offset -= (linear_velocity/roll_speed) * ROLLING_EFFECT_FACTOR
	if roll_mode == false:
		$BodyTexture.texture_offset = lerp($BodyTexture.texture_offset, Vector2(0,0), 0.5)


func check_if_in_control() -> bool:
	return linear_velocity.length() < control_velocity


func apply_force(delta) -> void:
	velocity = velocity * delta
	if roll_mode == true:
		velocity = velocity.normalized() * roll_speed
	else:
		velocity = velocity.normalized() * CRAWL_SPEED
	applied_force = velocity


func switch_mode() -> void:
	roll_mode = !roll_mode
	if roll_mode == true:
		$Weapon.hide()
		linear_damp = ROLL_MODE_DAMP
	if roll_mode == false:
		$Weapon.show()
		linear_damp = CRAWL_MODE_DAMP


func weapon_shoot() -> void:
	if $Weapon/Cooldown.is_stopped() == false || roll_mode == true:
		return
	emit_signal("shoot", $Weapon.get_projectile(),
		$Weapon/Muzzle.global_position, $Weapon/Muzzle.global_rotation)
	$Weapon/Cooldown.start()


func charge() -> void:
	if $ChargeCooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(Vector2(roll_speed,0).rotated(charge_direction) * CHARGE_FORCE_FACTOR)
	$ChargeCooldown.start()


func _on_ChargeCooldown_timeout() -> void:
	$ChargeCooldown.stop()
