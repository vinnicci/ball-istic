extends Area2D

#be sure to name root node as Projectile
#however you can name the scene as anything

export (int) var speed
export (int) var damage
export (float) var proj_range
var velocity: Vector2

func _travel(pos, dir) -> void:
	#scattershots and others could be implemented here
	
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
	$RangeTimer.stop()

func _on_Projectile_body_entered(_body: Node) -> void:
	pass
