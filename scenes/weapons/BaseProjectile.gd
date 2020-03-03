extends Area2D

export (int) var speed
export (int) var damage
export (float) var proj_range
var velocity: Vector2

func travel(pos, dir) -> void:
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
