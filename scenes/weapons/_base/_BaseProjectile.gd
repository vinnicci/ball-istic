extends Area2D


export (int) var speed: int = 500 setget , get_speed
export (float) var damage: float = 1
export (int) var proj_range: int = 500
export (int) var knockback: int = 50
export (float) var stun_time: float = 0

var velocity: Vector2
var acceleration: Vector2 = Vector2(0,0)
var current_speed: int
var is_stopped: bool = false
var is_crit: bool = false
var exploded: bool = false
var _level_node: Node = null
var _shooter: Node setget , shooter
var _shooter_faction: Color setget , shooter_faction


func get_speed():
	return speed

func shooter():
	return _shooter

func shooter_faction():
	return _shooter_faction


func _ready() -> void:
	var circle: Array = []
	for i in range(12):
		circle.append(Vector2($CollisionShape.shape.radius, 0).rotated(deg2rad(i * 30)))
	$HitBlast.polygon = circle
	#bullet behavior component
	if has_node("ProjBehavior") == true:
		$ProjBehavior.set_parent(self)
	current_speed = speed


func set_level(new_level: Node) -> void:
	if _level_node == new_level:
		return
	_level_node = new_level
	if has_node("ProjBehavior") == true:
		$ProjBehavior.set_level(_level_node)
	if has_node("Explosion") == true:
		$Explosion.set_level_cam(_level_node.get_node("Camera2D"))
		if is_instance_valid(_level_node.get_player()) == true:
			$Explosion.set_player_cam(_level_node.get_player().get_node("Camera2D"))


func set_shooter(shooter: Node, faction: Color) -> void:
	_shooter = shooter
	_shooter_faction = faction


func init_travel(pos: Vector2, dir: float) -> void:
	$RangeTimer.wait_time = float(proj_range) / float(current_speed)
	$RangeTimer.start()
	if is_crit == true && has_node("Explosion") == true:
		$Explosion.is_crit = true
	position = pos
	rotation = dir
	velocity = Vector2(current_speed, 0).rotated(rotation)


func _physics_process(delta: float) -> void:
	if is_stopped == true:
		$Sprite.modulate.a = 0
		return
	elif is_stopped == false && $RangeTimer.time_left <= 0.1:
		$Sprite.modulate.a = lerp($Sprite.modulate.a, 0, 0.1)
	velocity = (velocity + acceleration).normalized() * current_speed
	$Sprite.global_rotation = velocity.angle()
	translate(velocity * delta)
	acceleration = Vector2(0,0)


func _on_Projectile_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		_damage_bot(body)
	else:
		_damage_object(body)


func _damage_bot(bot: Node) -> void:
	if bot.current_faction == _shooter_faction:
		return
	elif bot.current_faction != _shooter_faction && bot.state == Global.CLASS_BOT.State.DEAD:
		return
	else:
		if has_node("Explosion") == true:
			$Explosion.start_explosion()
			exploded = true
		else:
			bot.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
			if is_crit == true:
				if stun_time != 0:
					bot.stun_effect(stun_time)
				bot.crit_effect()
		if bot.has_node("AI") == true && is_instance_valid(_shooter) == true:
			bot.get_node("AI").engage(_shooter)
		stop_projectile(bot)


#environment object such as walls or objects
func _damage_object(lvl_object: Node) -> void:
	if has_node("Explosion") == true:
		$Explosion.start_explosion()
	else:
		lvl_object.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	stop_projectile(lvl_object)


func _on_RangeTimer_timeout() -> void:
	stop_projectile()


#stop when max range or hitting something
func stop_projectile(body = null) -> void:
	#if projectile is explosive or not
	$RangeTimer.stop()
	is_stopped = true
	set_deferred("monitoring", false)
	_play_hit_blast_anim(body)
	if has_node("Explosion") == true:
		if exploded == false:
			$Explosion.start_explosion()
			exploded = true
		var explode_anim = $Explosion/Blast/Anim
		if explode_anim.is_playing() == true:
			_connect_blast_anim(explode_anim)
		else:
			_connect_blast_anim($HitBlast/Anim)
	else:
		_connect_blast_anim($HitBlast/Anim)


func _connect_blast_anim(node) -> void:
	#blast graphics upon object hit
	if node.is_connected("animation_finished", self, "_on_anim_finished") == false:
		node.connect("animation_finished", self, "_on_anim_finished")


func _play_hit_blast_anim(object) -> void:
	$HitBlast.show()
	if object is Global.CLASS_BOT && object.current_shield <= 0:
		$HitBlast/Anim.play("blast_big")
	else:
		$HitBlast/Anim.play("blast_small")
	$OnHitParticles.emitting = true


func _on_anim_finished(anim_name: String) -> void:
	queue_free()
