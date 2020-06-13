extends "res://scenes/level/_base/_BaseLevelObject.gd"


export (float) var knockback_resist: float = 0.2


func take_damage(damage, knockback) -> void:
	.take_damage(damage, knockback)
	get_node(".").apply_central_impulse(knockback)
	if current_health - damage > 0:
		current_health -= damage
	if current_health - damage <= 0:
		#apply breaking or explosion stuff here later
		queue_free()
