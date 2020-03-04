extends RigidBody2D

#eventually ??
#mode: Character --> rolling animations based on direction

#default bot values
export (int) var shield_capacity = 1000
export (int) var health_capacity = 500
export (int) var roll_speed = 1500
export (bool) var destructible = true
export (bool) var hostile = true
const CRAWL_SPEED = 1000
const CHARGE_FORCE_FACTOR: float = 0.5
const CHARGE_SPRITE_VELOCITY_FACTOR: float = 0.76
const NORMAL_SPRITE_VELOCITY_FACTOR: float = 0.6
const CONTROL_VELOCITY_FACTOR: float = 0.6
const ROLLING_EFFECT_FACTOR:float = 7.0
const ROLL_MODE_DAMP: int = 2
const CRAWL_MODE_DAMP: int = 5
var control_velocity: int
var roll_mode: bool = false
var is_charging: bool = false
var is_shooting: bool = false
var velocity: Vector2
signal shoot

func _ready() -> void:
	linear_damp = CRAWL_MODE_DAMP
	control_velocity = roll_speed * CONTROL_VELOCITY_FACTOR

func _control():
	pass

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass

func _physics_process(delta: float) -> void:
	#charge sprite effects
	check_for_charge_sprite_effects()
	
	#rolling sprite effect
	if roll_mode == true:
		$PaintJob.texture_offset -= (linear_velocity/roll_speed) * ROLLING_EFFECT_FACTOR
	if roll_mode == false:
		$PaintJob.texture_offset = Vector2(0,0)
	
	#bot loses control when it's more than control_velocity
	if check_if_in_control() == false:
		return
	
	#velocity calculations
	_control()
	apply_force(delta)
	
	#shooting weapon
	if is_shooting == true:
		weapon_shoot()
	
	#applying impulse on charge
	if is_charging == true:
		charge()
	

func check_for_charge_sprite_effects() -> void:
	if linear_velocity.length() > roll_speed * CHARGE_SPRITE_VELOCITY_FACTOR && $ChargeCooldown.is_stopped() == false:
		$ChargeSprite.show()
		$BodySprite.hide()
		$PaintJob.hide()
	if linear_velocity.length() < roll_speed * NORMAL_SPRITE_VELOCITY_FACTOR:
		$ChargeSprite.hide()
		$BodySprite.show()
		$PaintJob.show()

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
	is_shooting = false
	if $Weapon/Cooldown.is_stopped() == false || roll_mode == true:
		return
	emit_signal("shoot", $Weapon.get_projectile(),
		$Weapon/Muzzle.global_position, $Weapon/Muzzle.global_rotation)
	$Weapon/Cooldown.start()

func charge() -> void:
	is_charging = false
	if $ChargeCooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(applied_force * CHARGE_FORCE_FACTOR)
	$ChargeCooldown.start()

func _on_ChargeCooldown_timeout() -> void:
	$ChargeCooldown.stop()
