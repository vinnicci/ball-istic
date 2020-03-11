extends RigidBody2D


export (int) var health_capacity = 1000
export (bool) var destructible = false
var current_health: int


func _ready() -> void:
	current_health = health_capacity


func take_damage(damage, knockback) -> void:
	apply_central_impulse(knockback)
	if destructible == false:
		return
	if current_health - damage > 0:
		current_health -= damage
	if current_health - damage <= 0:
		queue_free()
