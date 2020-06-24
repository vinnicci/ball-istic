extends Node2D


export (float) var explosion_radius: float = 100 setget , get_radius
export (float) var damage: float = 15 setget , get_damage
export (float) var knockback: float = 500 setget , get_knockback

const PARTICLEV_RADIUS_RATIO: float = 0.35
var _player: Global.CLASS_PLAYER = null
var _level_cam: Node = null

func get_radius():
	return explosion_radius

func get_damage():
	return damage

func get_knockback():
	return knockback


func _ready() -> void:
	_init_explosion()


func set_player(player: Global.CLASS_PLAYER) -> void:
	_player = player


func set_level_cam(level_cam: Camera2D) -> void:
	_level_cam = level_cam


func _init_explosion() -> void:
	#set radius
	$AreaOfEffect/CollisionShape2D.shape.radius = explosion_radius
	$KnockBackDirection.cast_to = Vector2(explosion_radius, 0)
	var circle: Array = []
	for i in range(24):
		circle.append(Vector2(explosion_radius, 0).rotated(deg2rad(i * 15)))
	$Blast.polygon = circle
	#particle velocity
	$Particles2D.process_material.initial_velocity = (explosion_radius/PARTICLEV_RADIUS_RATIO) as int


func start_explosion() -> void:
	if ((is_instance_valid(_player) && _player.state != Global.CLASS_BOT.State.DEAD) &&
		global_position.distance_to(_player.global_position) < explosion_radius * 4):
		_player.get_node("Camera2D").shake_camera(20, 0.05, 0.05, 1)
	elif global_position.distance_to(_level_cam.global_position) < explosion_radius * 4:
		_level_cam.shake_camera(20, 0.1, 0.1, 1)
	var bodies = $AreaOfEffect.get_overlapping_bodies()
	for body in bodies:
		if body == get_parent():
			continue
		_apply_effect(body)
	$Blast.show()
	var tween = $Blast/BlastTween
	tween.interpolate_property($Blast, "scale", $Blast.scale, Vector2(2,2), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property($Blast, "modulate", $Blast.modulate, Color(1,1,1,0),
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$Particles2D.emitting = true
	$RemoveParticles.start()
	$Sound.play()


func _apply_effect(body: Node) -> void:
	$KnockBackDirection.look_at(body.global_position)
	if body.has_method("take_damage") == true:
		body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))


func _on_RemoveParticles_timeout() -> void:
	$Particles2D.hide()
	queue_free()
