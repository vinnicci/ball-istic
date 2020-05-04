extends Area2D


export (int) var speed: = 500
export (float) var damage: = 5
export (int) var proj_range: = 500
export (float) var knockback: = 50

var _origin: bool
var _proj_velocity: Vector2


func _ready() -> void:
	var circle: Array = []
	for i in range(12):
		circle.append(Vector2($CollisionShape.shape.radius, 0).rotated(deg2rad(i * 30)))
	$HitBlast.polygon = circle


func ready_travel(pos, dir, origin) -> void:
	_origin = origin
	$RangeTimer.wait_time = proj_range as float/speed as float
	$RangeTimer.start()
	_travel(pos, dir)
	_proj_velocity = Vector2(speed,0).rotated(rotation)


#virtual func for proj behavior while travelling
#use for random behaviors, such as homing, splitting etc.
func _travel(pos, dir):
	position = pos
	rotation = dir


func _physics_process(delta: float) -> void:
	position += _proj_velocity * delta


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
	_proj_velocity = Vector2(0,0)
	$Sprite.hide()
	set_deferred("monitoring", false)


func _on_RemoveTimer_timeout() -> void:
	queue_free()
