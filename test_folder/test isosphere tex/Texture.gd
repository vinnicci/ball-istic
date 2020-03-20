extends Polygon2D

#func _ready() -> void:
#	var circle_points = []
#	for i in range(24):
#		circle_points.append(Vector2(1,0).rotated(deg2rad(i*15)))


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		texture_offset.y += 100 * delta
	elif Input.is_action_pressed("ui_down"):
		texture_offset.y -= 100 * delta
	if Input.is_action_pressed("ui_left"):
		texture_offset.x += 100 * delta
	elif Input.is_action_pressed("ui_right"):
		texture_offset.x -= 100 * delta
