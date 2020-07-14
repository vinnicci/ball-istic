extends Area2D


export (int) var speed: int = 500 setget , get_speed
export (float) var damage: float = 1
export (int) var proj_range: int = 500 setget , get_range
export (float) var knockback: float = 50 setget , get_knockback
export (float) var stun_time: float = 0 setget , get_stun_time

var velocity: Vector2
var acceleration: Vector2 = Vector2(0,0)
var current_speed: int
var _shooter: Node
var _shooter_faction: Color setget , shooter_faction
var is_stopped: bool = false
var _level_node: Node = null
var is_crit: bool = false
var _crit_feedback: = load("res://scenes/global/feedback/Critical.tscn")
var _stun_feedback: = load("res://scenes/global/feedback/Stun.tscn")


func get_speed():
	return speed

func get_range():
	return proj_range

func get_knockback():
	return knockback

func get_stun_time():
	return stun_time

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


func set_level(new_level: Node) -> void:
	_level_node = new_level
	if has_node("ProjBehavior") == true:
		$ProjBehavior.set_level(_level_node)
	if has_node("Explosion") == true:
		$Explosion.set_level_cam(_level_node.get_node("Camera2D"))
		if is_instance_valid(_level_node.get_player()) == true:
			$Explosion.set_player_cam(_level_node.get_player().get_node("Camera2D"))


func set_shooter(shooter: Node) -> void:
	_shooter = shooter


func init_travel(pos: Vector2, dir: float, shooter_faction: Color) -> void:
	_shooter_faction = shooter_faction
	$RangeTimer.wait_time = proj_range as float/current_speed as float
	$RangeTimer.start()
	if is_crit == true && has_node("Explosion") == true:
		$Explosion.is_crit = true
	position = pos
	rotation = dir
	velocity = Vector2(current_speed, 0).rotated(rotation)


func _physics_process(delta: float) -> void:
	if is_stopped == true:
		velocity = Vector2(0,0)
		$Sprite.hide()
		return
	elif (is_stopped == false && $RangeTimer.time_left <= 0.1):
		$Sprite.modulate.a = lerp($Sprite.modulate.a, 0, 0.1)
	velocity += acceleration
	velocity = velocity.normalized() * current_speed
	$Sprite.global_rotation = velocity.angle()
	position += velocity * delta
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
		else:
			bot.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
			if is_crit == true:
				if stun_time != 0:
					bot.timer_stun.start(stun_time)
				_play_crit_effect(bot.global_position)
		if bot.has_node("AI") == true && is_instance_valid(_shooter):
			bot.get_node("AI").engage_attacker(_shooter)
		stop_projectile(bot)


#crit feedback only works on bots
#although damage also works on walls
func _play_crit_effect(pos: Vector2) -> void:
	var crit_node = _crit_feedback.instance()
	_level_node.add_child(crit_node)
	crit_node.global_position = pos
	var crit_anim = crit_node.get_node("Anim")
	crit_anim.connect("animation_finished", _level_node, "_on_Anim_finished",
		[crit_node])
	crit_anim.play("critical")
	if stun_time == 0:
		return
	var stun_node = _stun_feedback.instance()
	_level_node.add_child(stun_node)
	stun_node.global_position = pos
	var stun_anim = stun_node.get_node("Anim")
	stun_anim.connect("animation_finished", _level_node, "_on_Anim_finished",
		[stun_node])
	stun_anim.play("stun")


#environment object such as walls or objects
func _damage_object(lvl_object: Node) -> void:
	if has_node("Explosion") == true:
		$Explosion.start_explosion()
	else:
		lvl_object.take_damage(damage, Vector2(knockback, 0).rotated(rotation))
	stop_projectile(lvl_object)


func _on_RangeTimer_timeout() -> void:
	stop_projectile(null)


#stop when max range or hitting something
func stop_projectile(body = null) -> void:
	#if projectile is explosive or not
	$RangeTimer.stop()
	is_stopped = true
	set_deferred("monitoring", false)
	if has_node("Explosion") == true:
		$Explosion/Blast/Anim.connect("animation_finished", self, "_on_anim_finished")
	else:
		#blast graphics upon object hit
		_play_hit_blast_anim(body)
		var blast_anim = $HitBlast/Anim
		if !blast_anim.is_connected("animation_finished", self, "_on_anim_finished"):
			blast_anim.connect("animation_finished", self, "_on_anim_finished")


func _play_hit_blast_anim(object) -> void:
	$HitBlast.show()
	if object is Global.CLASS_BOT && object.current_shield <= 0:
		$HitBlast/Anim.play("blast_big")
	else:
		$HitBlast/Anim.play("blast_small")
	$OnHitParticles.emitting = true


func _on_anim_finished(anim_name: String) -> void:
	queue_free()
