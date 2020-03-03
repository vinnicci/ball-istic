extends RigidBody2D

#eventually ??
#mode: Character --> rolling animations based on direction

#default bot values
export (int) var roll_speed = 1500
const CRAWL_SPEED = 1000
const CHARGE_FORCE_FACTOR: float = 0.5
const CHARGE_SPRITE_VELOCITY_FACTOR: float = 0.76
const NORMAL_SPRITE_VELOCITY_FACTOR: float = 0.6
const CONTROL_VELOCITY_FACTOR: float = 0.6
const ROLL_MODE_DAMP: int = 2
const CRAWL_MODE_DAMP: int = 5
var control_velocity: int
var roll_mode: bool = false
var is_charging: bool = false
var is_shooting: bool = false
var velocity: Vector2

func _ready() -> void:
	linear_damp = CRAWL_MODE_DAMP
	control_velocity = roll_speed * CONTROL_VELOCITY_FACTOR

func _control():
	pass

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass

func _physics_process(delta: float) -> void:
	#bot loses control when it's more than control_velocity
	if check_if_in_control() == false:
		return
	
	#velocity calculations
	_control()
	apply_force(delta)
	
	#shooting weapon
	if is_shooting == true:
		shoot()
	
	#applying impulse on charge
	if is_charging == true:
		charge()

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

func shoot() -> void:
	is_shooting = false
	if $Weapon/ShootCooldown.is_stopped() == false || roll_mode == true:
		return
	
	#shoot logic here
	
	$Weapon/ShootCooldown.start()

func charge() -> void:
	is_charging = false
	if $ChargeCooldown.is_stopped() == false || roll_mode == false:
		return
	apply_central_impulse(velocity * CHARGE_FORCE_FACTOR)
	$ChargeCooldown.start()

func _on_ChargeCooldown_timeout() -> void:
	$ChargeCooldown.stop()

func _on_WeaponShootCooldown_timeout() -> void:
	$Weapon/ShootCooldown.stop()
