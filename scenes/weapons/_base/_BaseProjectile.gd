extends Area2D


export (int) var speed: = 500
export (float) var damage: = 5
export (int) var proj_range: = 500
export (float) var knockback: = 50

var proj_origin: bool
var velocity: Vector2


func _ready() -> void:
	var circle: Array = []
	for i in range(12):
		circle.append(Vector2($CollisionShape.shape.radius, 0).rotated(deg2rad(i * 30)))
	$Blast.polygon = circle


func ready_travel(pos, dir, origin) -> void:
	proj_origin = origin
	$RangeTimer.wait_time = proj_range as float/speed as float
	$RangeTimer.start()
	_travel(pos, dir)
	velocity = Vector2(speed,0).rotated(rotation)


#virtual func for proj behavior while travelling
func _travel(pos, dir):
	position = pos
	rotation = dir


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_Projectile_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile == proj_origin:
		return
	elif body.get_parent().name == "Bots" && body.is_hostile != proj_origin:
		body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	else:
		body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	velocity = Vector2(0,0)
	$Sprite.hide()
	$Blast.show()
	$Blast/AnimationPlayer.play("blast")
	$OnHitParticles.emitting = true
	set_deferred("monitoring", false)


func _on_RangeTimer_timeout() -> void:
	velocity = Vector2(0,0)
	$Sprite.hide()
	$RemoveTimer.start()
	set_deferred("monitoring", false)
	

func _on_RemoveTimer_timeout() -> void:
	queue_free()
