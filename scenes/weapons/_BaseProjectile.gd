extends Area2D


#be sure to name root node as Projectile
#however you can name the scene as anything
export (int) var speed = 1000
export (int) var damage = 5
export (float) var proj_range = 500
export (float) var knockback = 0 #absolute max is 0.5
var proj_origin: bool
var velocity: Vector2


func _ready() -> void:
	if knockback > 0.5:
		knockback = 0.5


func ready_travel(pos, dir, origin) -> void:
	proj_origin = origin
	$RangeTimer.wait_time = proj_range/speed
	$RangeTimer.start()
	_travel(pos, dir)
	velocity = speed * Vector2(1,0).rotated(rotation).normalized()


#virtual func for proj behavior while travelling
func _travel(pos, dir):
	pass


func _process(delta: float) -> void:
	position += velocity * delta


func _on_Projectile_body_entered(_body: Node) -> void:
	if _body.get_parent().name == "Bots" && _body.is_hostile == proj_origin:
		return
	elif _body.get_parent().name == "Bots" && _body.is_hostile != proj_origin:
		_body.take_damage(damage, velocity * knockback)
		velocity = Vector2(0,0)
	else:
		_body.take_damage(damage, velocity * knockback)
		velocity = Vector2(0,0)
	set_deferred("monitoring", false)
	$Sprite.hide()
	$OnHitParticles.emitting = true


func _on_RangeTimer_timeout() -> void:
	set_deferred("monitoring", false)
	$Sprite.hide()
	$RemoveTimer.start()


func _on_RemoveTimer_timeout() -> void:
	queue_free()
