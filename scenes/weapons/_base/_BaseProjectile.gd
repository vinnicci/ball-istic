extends Area2D


export (int) var speed: = 500
export (float) var damage: = 5
export (int) var proj_range: = 500
export (float) var knockback: = 50

var velocity: Vector2
var acceleration: Vector2
var current_speed: int
var _shooter: Node setget , shooter
var _origin: bool setget , origin
var _is_stopped: bool = false setget set_stopped_status, is_stopped
var _exploded: bool = false


func shooter():
	return _shooter

func origin():
	return _origin

func set_stopped_status(state: bool):
	_is_stopped = state

func is_stopped():
	return _is_stopped


func _ready() -> void:
	current_speed = speed
	var circle: Array = []
	for i in range(12):
		circle.append(Vector2($CollisionShape.shape.radius, 0).rotated(deg2rad(i * 30)))
	$HitBlast.polygon = circle
	#bullet behavior component
	if has_node("ProjBehavior") == true:
		$ProjBehavior.set_parent(self)


func init_travel(pos: Vector2, dir: float, origin: bool, shooter: Node) -> void:
	if shooter != null:
		_shooter = shooter
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
	$Sprite.global_rotation = velocity.angle()
	velocity = velocity.normalized() * current_speed
	position += velocity * delta
	acceleration = Vector2(0,0)


func _on_Projectile_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		if body.is_hostile() == _origin:
			return
		elif body.is_hostile() != _origin && body.state == Global.CLASS_BOT.State.DEAD:
			return
		else:
			if has_node("Explosion") == true:
				$Explosion.start_explosion()
			else:
				body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	else:
		if has_node("Explosion") == true:
			$Explosion.start_explosion()
		else:
			body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	if has_node("Explosion") == true:
		_exploded = true
	else:
		$HitBlast.show()
		$HitBlast/AnimationPlayer.play("blast")
		$OnHitParticles.emitting = true
	_stop_projectile()


func _on_RangeTimer_timeout() -> void:
	if has_node("Explosion") && _exploded == false:
		$Explosion.start_explosion()
	_stop_projectile()


#stop when max range or hitting something
func _stop_projectile() -> void:
	_is_stopped = true
	set_deferred("monitoring", false)
	$Sprite.hide()
	$RemoveTimer.start()


func _on_RemoveTimer_timeout() -> void:
	queue_free()
