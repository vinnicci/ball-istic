extends "res://scenes/weapons/_base/_BaseWeapon.gd"


export (float) var damage: float = 20
export (float) var knockback: float = 500


func _process(delta: float) -> void:
	if _parent_node is Global.CLASS_BOT && _parent_node.state == Global.CLASS_BOT.State.DEAD:
		$Beams/Beam1/HurtBox.monitoring = false
		$Beams/Beam2/HurtBox.monitoring = false
		$Beams.hide()


func _fire_other() -> void:
	weap_commit = true
	$ShootingSound.play()
	_apply_recoil()
	$Beams/Anim.play("attack")


func _on_HurtBox_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		if body.current_faction == _parent_node.current_faction:
			return
		elif body.current_faction != _parent_node.current_faction && body.state == Global.CLASS_BOT.State.DEAD:
			return
		else:
			body.take_damage(damage * proj_damage_rate, Vector2(knockback, 0).rotated(rotation))
	else:
		body.take_damage(damage * proj_damage_rate, Vector2(knockback, 0).rotated(rotation))


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
