extends Area2D


export (int) var speed: = 500
export (float) var damage: = 5
export (int) var proj_range: = 500
export (float) var knockback: = 0.01
var proj_origin: bool
var velocity: Vector2


func _ready() -> void:
	if knockback > 0.5:
		knockback = 0.5


func ready_travel(pos, dir, origin) -> void:
	proj_origin = origin
	$RangeTimer.wait_time = proj_range as float/speed as float
	$RangeTimer.start()
	_travel(pos, dir)
	velocity = speed * Vector2(1,0).rotated(rotation).normalized()


#virtual func for proj behavior while travelling
func _travel(pos, dir):
	pass


func _physics_process(delta: float) -> void:
	pass


func _process(delta: float) -> void:
	position += velocity * delta


func _on_Projectile_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile == proj_origin:
		return
	elif body.get_parent().name == "Bots" && body.is_hostile != proj_origin:
		#projectile effects here
		#body.take_projectile_effect(some params)
		
		#normal damage
		body.take_damage(damage, velocity*knockback)
		velocity = Vector2(0,0)
	else:
		body.take_damage(damage, velocity*knockback)
		velocity = Vector2(0,0)
	$Sprite.hide()
	$OnHitParticles.emitting = true
	set_deferred("monitoring", false)


func _on_RangeTimer_timeout() -> void:
	$Sprite.hide()
	$RemoveTimer.start()
	set_deferred("monitoring", false)
	

func _on_RemoveTimer_timeout() -> void:
	queue_free()
