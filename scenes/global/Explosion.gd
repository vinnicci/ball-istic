extends Node2D


export (float) var explosion_radius: float = 100
export (float) var damage: float = 15
export (float) var knockback: float = 500


func _ready() -> void:
	#set radius
	$AreaOfEffect/CollisionShape2D.shape.radius = explosion_radius
	$KnockBackDirection.cast_to = Vector2(explosion_radius, 0)
	var circle: Array
	for i in range(24):
		circle.append(Vector2(explosion_radius, 0).rotated(deg2rad(i * 15)))
	$Blast.polygon = circle


func start_explosion() -> void:
	var bodies = $AreaOfEffect.get_overlapping_bodies()
	for body in bodies:
		$KnockBackDirection.look_at(body.global_position)
		if body.has_method("take_damage") == true:
			body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
	$Blast.show()
	var blast_anim = $Blast/AnimationPlayer
	blast_anim.play("blast")
	$AreaOfEffect.set_deferred("monitoring", false)
	$Particles2D.emitting = true
	$Sound.play()
