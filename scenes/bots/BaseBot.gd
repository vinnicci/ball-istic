extends RigidBody2D

#eventually ??
#mode: Character --> rolling animations based on direction

export (int) var roll_speed
var charge_ready: bool = true
var control_velocity: int
const CONTROL_VELOCITY_FACTOR: float = 0.6
var velocity: Vector2
var roll_mode: bool = false
const ROLL_MODE_DAMP: int = 2
const CRAWL_MODE_DAMP: int = 5
var charging: bool = false
const CHARGE_FORCE_MULT: float = 0.5
const CRAWL_SPEED = 1000

func _ready() -> void:
	control_velocity = roll_speed * CONTROL_VELOCITY_FACTOR

func _control():
	pass

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass

func _physics_process(delta: float) -> void:
	#properties adjustment when changing mode
	adjust_properties()
	
	#bot loses control when it reaches high speed
	if check_if_in_control() == false:
		return
	
	#virtual control and velocity calculations
	_control()
	apply_force(delta)
	
	#impulse application on charge
	if charging == true:
		charge()

func adjust_properties() -> void:
	if roll_mode == true:
		linear_damp = ROLL_MODE_DAMP
	if roll_mode == false:
		linear_damp = CRAWL_MODE_DAMP

func check_if_in_control() -> bool:
	return linear_velocity.length() < control_velocity

func apply_force(delta) -> void:
	velocity = velocity*delta
	if roll_mode == true:
		velocity = velocity.normalized() * roll_speed
	else:
		velocity = velocity.normalized() * CRAWL_SPEED
	applied_force = velocity

func charge() -> void:
	charging = false
	if charge_ready == false:
		return
	apply_central_impulse(velocity * CHARGE_FORCE_MULT)
	charge_ready = false
	$ChargeCooldown.start()

func _on_ChargeCooldown_timeout() -> void:
	charge_ready = true
	$ChargeCooldown.stop()
