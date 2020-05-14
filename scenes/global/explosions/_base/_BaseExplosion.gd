extends Node2D


export (float) var explosion_radius: float = 100
export (float) var damage: float = 15
export (float) var knockback: float = 500

const PARTICLEV_RADIUS_RATIO: float = 0.35


func _ready() -> void:
	_init_explosion()


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
	if Global.player.is_alive() == true && global_position.distance_to(Global.player.global_position) < explosion_radius * 4:
		Global.player.get_node("Camera2D").shake_camera(30, 0.1, 0.1, 1)
	elif global_position.distance_to(Global.current_level.get_node("Camera2D").global_position) < explosion_radius * 4:
		Global.current_level.get_node("Camera2D").shake_camera(30, 0.1, 0.1, 1)
	var bodies = $AreaOfEffect.get_overlapping_bodies()
	for body in bodies:
		$KnockBackDirection.look_at(body.global_position)
		if body.has_method("take_damage") == true:
			body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
	$Blast.show()
	$Blast/AnimationPlayer.play("blast")
	$Particles2D.emitting = true
	$RemoveParticles.start()
	$Sound.play()
	$AreaOfEffect.set_deferred("monitoring", false)


func _on_RemoveParticles_timeout() -> void:
	$Particles2D.hide()
