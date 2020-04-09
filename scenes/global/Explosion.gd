extends Node2D


export (float) var explosion_radius: float = 100
export (float) var damage: float = 15
export (float) var knockback: float = 500

const PARTICLEV_RADIUS_RATIO: float = 0.35


func _ready() -> void:
	#set radius
	$AreaOfEffect/CollisionShape2D.shape.radius = explosion_radius
	$KnockBackDirection.cast_to = Vector2(explosion_radius, 0)
	var circle: Array
	for i in range(24):
		circle.append(Vector2(explosion_radius, 0).rotated(deg2rad(i * 15)))
	$Blast.polygon = circle
	#particle velocity
	$Particles2D.process_material.initial_velocity = (explosion_radius/PARTICLEV_RADIUS_RATIO) as int


func start_explosion() -> void:
	var bodies = $AreaOfEffect.get_overlapping_bodies()
	for body in bodies:
		$KnockBackDirection.look_at(body.global_position)
		if body.has_method("take_damage") == true:
			body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
	$Blast.show()
	$Blast/AnimationPlayer.play("blast")
	$Particles2D.emitting = true
	$AreaOfEffect.set_deferred("monitoring", false)
	$Sound.play()
