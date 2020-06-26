extends Area2D


export (int) var speed: int = 500 setget , get_speed
export (float) var damage: float = 1
export (int) var proj_range: int = 500 setget , get_range
export (float) var knockback: float = 50 setget , get_knockback

var velocity: Vector2
var acceleration: Vector2
var current_speed: int
var _shooter: Node setget , shooter
var _shooter_faction: Color setget , shooter_faction
var level_node: Node = null
var is_stopped: bool = false
var _exploded: bool = false


func get_speed():
	return speed

func get_range():
	return proj_range

func get_knockback():
	return knockback

func shooter():
	return _shooter

func shooter_faction():
	return _shooter_faction


func _ready() -> void:
	current_speed = speed
	var circle: Array = []
	for i in range(12):
		circle.append(Vector2($CollisionShape.shape.radius, 0).rotated(deg2rad(i * 30)))
	$HitBlast.polygon = circle
	#bullet behavior component
	if has_node("ProjBehavior") == true:
		$ProjBehavior.set_parent(self)


func init_travel(pos: Vector2, dir: float, shooter_faction: Color, shooter: Node) -> void:
	_shooter_faction = shooter_faction
	$RangeTimer.wait_time = proj_range as float/current_speed as float
	$RangeTimer.start()
	position = pos
	rotation = dir
	velocity = Vector2(current_speed, 0).rotated(rotation)


func _physics_process(delta: float) -> void:
	if is_stopped == true:
		velocity = Vector2(0,0)
		return
	velocity += acceleration
	velocity = velocity.normalized() * current_speed
	$Sprite.global_rotation = velocity.angle()
	position += velocity * delta
	acceleration = Vector2(0,0)


func _on_Projectile_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT && _damage_bot(body) == false:
		return
	else:
		_damage_object(body)
	
	#if projectile is explosive or not
	if has_node("Explosion") == true:
		_exploded = true
	else:
		#blast graphics upon object hit
		_play_hit_blast_anim(body)
	_stop_projectile()


func _damage_bot(bot: Node) -> bool:
	if bot.current_faction == _shooter_faction:
		return false
	elif bot.current_faction != _shooter_faction && bot.state == Global.CLASS_BOT.State.DEAD:
		return false
	else:
		if has_node("Explosion") == true:
			$Explosion.start_explosion()
		else:
			bot.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
		return true


#environment object such as walls or objects
func _damage_object(object: Node) -> void:
	if has_node("Explosion") == true:
		$Explosion.start_explosion()
	else:
		object.take_damage(damage, Vector2(knockback, 0).rotated(rotation))


func _play_hit_blast_anim(object) -> void:
	$HitBlast.show()
	if object is Global.CLASS_BOT && object.current_shield <= 0:
		$HitBlast/Anim.play("blast_big")
	else:
		$HitBlast/Anim.play("blast_small")
	$OnHitParticles.emitting = true


func _on_RangeTimer_timeout() -> void:
	if has_node("Explosion") && _exploded == false:
		$Explosion.start_explosion()
	_stop_projectile()


#stop when max range or hitting something
func _stop_projectile() -> void:
	is_stopped = true
	set_deferred("monitoring", false)
	$Sprite.hide()
	$RemoveTimer.start()


func _on_RemoveTimer_timeout() -> void:
	queue_free()
