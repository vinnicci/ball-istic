extends Area2D


export (float) var explosion_radius: float = 100 setget , get_radius
export (float) var damage: float = 15 setget , get_damage
export (float) var knockback: float = 500 setget , get_knockback

const PARTICLEV_RADIUS_RATIO: float = 0.35
var _player_cam: Camera2D = null
var _level_cam: Camera2D = null
var crit_node: Node = null


func get_radius():
	return explosion_radius

func get_damage():
	return damage

func get_knockback():
	return knockback


func _ready() -> void:
	_init_explosion()


func set_player_cam(player_cam: Camera2D) -> void:
	_player_cam = player_cam


func set_level_cam(level_cam: Camera2D) -> void:
	_level_cam = level_cam


func _init_explosion() -> void:
	#set radius
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = explosion_radius
	$KnockBackDirection.cast_to = Vector2(explosion_radius, 0)
	var circle: Array = []
	for i in range(24):
		circle.append(Vector2(explosion_radius, 0).rotated(deg2rad(i * 15)))
	$Blast.polygon = circle
	#particle velocity
	$Particles2D.process_material.initial_velocity = (explosion_radius/PARTICLEV_RADIUS_RATIO) as int


func start_explosion() -> void:
	if is_instance_valid(_player_cam) && (_player_cam.get_parent().state != Global.CLASS_BOT.State.DEAD &&
		global_position.distance_to(_player_cam.global_position) < explosion_radius * 3):
		_player_cam.shake_camera(20, 0.05, 0.05, 1)
	elif global_position.distance_to(_level_cam.global_position) < explosion_radius * 3:
		_level_cam.shake_camera(20, 0.1, 0.1, 1)
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body != get_parent():
			_apply_effect(body)
	$Blast/Anim.play("explode")
	$Particles2D.emitting = true
	$RemoveParticles.start()
	$Sound.play()


func _apply_effect(body: Node) -> void:
	$KnockBackDirection.look_at(body.global_position)
	if body.has_method("take_damage") == true:
		body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
		if crit_node != null && body is Global.CLASS_BOT:
			_play_crit_effect(body.global_position)


#crit feedback only works on bots
#although damage also works on walls
func _play_crit_effect(pos: Vector2) -> void:
	var level_node = _level_cam.get_parent()
	var crit_clone = crit_node.duplicate()
	level_node.add_child(crit_clone)
	var crit_anim = crit_clone.get_node("Anim")
	crit_clone.show()
	crit_clone.global_position = pos
	crit_clone.global_rotation = 0
	crit_anim.connect("animation_finished", level_node, "_on_Crit_anim_finished",
		[crit_clone])
	crit_anim.play("feedback")


func _on_RemoveParticles_timeout() -> void:
	$Particles2D.hide()
	queue_free()
