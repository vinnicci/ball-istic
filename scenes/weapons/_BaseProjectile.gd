extends Area2D


#be sure to name root node as Projectile
#however you can name the scene as anything
export (int) var speed = 1000
export (float) var damage = 5
export (float) var proj_range = 0.5
var proj_origin: bool
var velocity: Vector2


func ready_travel(pos, dir, origin) -> void:
	proj_origin = origin
	$RangeTimer.wait_time = proj_range
	$RangeTimer.start()
	_travel(pos, dir)
	velocity = speed * Vector2(1,0).rotated(rotation).normalized()


#virtual func for proj behavior while travelling
func _travel(pos, dir):
	pass


func _process(delta: float) -> void:
	position += velocity * delta


func _on_RangeTimer_timeout() -> void:
	queue_free()


func _on_Projectile_body_entered(_body: Node) -> void:
	if _body.get_parent().name == "Bots" && _body.is_hostile != proj_origin:
		_body.take_damage(damage)
	elif _body.get_parent().name == "Bots" && _body.is_hostile == proj_origin:
		return
	else:
		_body.take_damage(damage)
	queue_free()
