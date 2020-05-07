extends "res://scenes/level/_base/_BaseLevelObject.gd"


export (float) var knockback_resist: = 0.2


func take_damage(damage, knockback) -> void:
	.take_damage(damage, knockback)
	get_node(".").apply_central_impulse(knockback)
	if _current_health - damage > 0:
		_current_health -= damage
	if _current_health - damage <= 0:
		#apply breaking or explosion later
		queue_free()
