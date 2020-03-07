extends Area2D

#be sure to name root node as Projectile
#however you can name the scene as anything

export (int) var speed
export (int) var damage
export (float) var proj_range
var hostile_projectile: bool
var velocity: Vector2

func _travel(pos, dir, origin) -> void:
	#scattershots and others could be implemented here
	hostile_projectile = origin
	
	#vanilla projectile implementation
	$RangeTimer.wait_time = proj_range
	$RangeTimer.start()
	position = pos
	rotation = dir
	velocity = speed * Vector2(1,0).rotated(dir).normalized()

func _process(delta: float) -> void:
	position += velocity * delta

func _on_RangeTimer_timeout() -> void:
	queue_free()

func _on_Projectile_body_entered(_body: Node) -> void:
	if _body.destructible == false:
		queue_free()
		return
	if _body.has_method("take_damage") && _body.hostile != hostile_projectile:
		_body.take_damage(damage)
		queue_free()
