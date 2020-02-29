extends RigidBody2D

export (int) var roll_speed
export (int) var crawl_speed
var velocity: Vector2
var roll_mode: bool = false
var in_control: bool = true
var charging: bool = false
const CHARGE_FORCE_MULT: float = 0.6

func _control():
	pass

func _physics_process(delta: float) -> void:
	if linear_velocity.length() >= 1000:
		in_control = false
	else:
		in_control = true
	if in_control == false:
		return
	_control()
	velocity = velocity*delta

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if roll_mode == true:
		velocity = velocity.normalized() * roll_speed
	else:
		velocity = velocity.normalized() * crawl_speed
	if charging == true:
		if roll_mode == true:
			apply_central_impulse(velocity * CHARGE_FORCE_MULT)
		charging = false
	applied_force = velocity

