extends RigidBody2D


export (float) var health_capacity: = 1000.0
export (bool) var destructible: = false setget , is_destructible
export (float) var knockback_resist: = 0.2

var _current_health: float


func is_destructible():
	return destructible


func take_damage(damage, knockback) -> void:
	apply_central_impulse(knockback)
	if destructible == false:
		return
	if _current_health - damage > 0:
		_current_health -= damage
	if _current_health - damage <= 0:
		queue_free()
