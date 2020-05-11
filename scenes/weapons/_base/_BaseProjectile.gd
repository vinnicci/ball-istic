extends Area2D


export (int) var speed: = 500
export (float) var damage: = 5
export (int) var proj_range: = 500
export (float) var knockback: = 50

var velocity: Vector2
var acceleration: Vector2
var current_speed: int
var _origin: bool setget , origin
var _is_stopped: bool = false setget , is_stopped


func origin():
	return _origin

func is_stopped():
	return _is_stopped


func _ready() -> void:
	current_speed = speed
	var circle: Array = []
	for i in range(12):
		circle.append(Vector2($CollisionShape.shape.radius, 0).rotated(deg2rad(i * 30)))
	$HitBlast.polygon = circle


func init_travel(pos, dir, origin) -> void:
	_origin = origin
	$RangeTimer.wait_time = proj_range as float/current_speed as float
	$RangeTimer.start()
	position = pos
	rotation = dir
	velocity = Vector2(current_speed, 0).rotated(rotation)


func _physics_process(delta: float) -> void:
	if _is_stopped == true:
		velocity = Vector2(0,0)
		return
	velocity += acceleration
	velocity = velocity.normalized() * current_speed
	position += velocity * delta
	acceleration = Vector2(0,0)


func _on_Projectile_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		if body.is_hostile() == _origin:
			return
		elif body.is_hostile() != _origin && body.is_alive() == false:
			return
		else:
			body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	else:
		body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	$HitBlast.show()
	$HitBlast/AnimationPlayer.play("blast")
	$OnHitParticles.emitting = true
	_stop_projectile()


func _on_RangeTimer_timeout() -> void:
	$RemoveTimer.start()
	_stop_projectile()


#common steps to stop projectile
func _stop_projectile() -> void:
	_is_stopped = true
	$Sprite.hide()
	set_deferred("monitoring", false)


func _on_RemoveTimer_timeout() -> void:
	queue_free()
