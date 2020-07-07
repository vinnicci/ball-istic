extends Node


export (bool) var destructible: bool = false setget , is_destructible
export (float) var health_capacity: float = 1000.0 setget , get_health_capacity

var current_health: float


func is_destructible():
	return destructible

func get_health_capacity():
	return health_capacity


func _ready() -> void:
	current_health = health_capacity


func take_damage(damage, _knockback) -> void:
	if destructible == false:
		return
	current_health -= damage
	if has_node("HitSound") == true:
		$HitSound.play()
	if current_health <= 0:
		current_health = 0
		destroy()


func destroy() -> void:
	pass
