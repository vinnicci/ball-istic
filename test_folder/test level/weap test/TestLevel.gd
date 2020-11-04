extends "res://scenes/level/_base/_BaseLevel.gd"

#func get_points(start: Vector2, end: Vector2) -> Array:
#	var points: Array = $Nav.get_simple_path(start, end)
#	var line = Line2D.new()
#	line.points = points
#	add_child(line)
#	var tween = Tween.new()
#	line.add_child(tween)
#	tween.interpolate_property(line, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
#	tween.connect("tween_all_completed", self, "on_line_faded", [line])
#	return points


func _ready() -> void:
	pass
#	Engine.time_scale = 0.3
#	for bot in $Bots.get_children():
#		if bot != get_player():
#			bot.get_node("AI").set_master(get_player())
