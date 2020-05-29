extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _damage: float = 45
var _knockback: float = 800


func _process(delta: float) -> void:
	if _parent_node is Global.CLASS_BOT && _parent_node.is_alive() == false:
		$Beams/Beam1/HurtBox.monitoring = false
		$Beams/Beam2/HurtBox.monitoring = false


func _fire_other() -> void:
	_parent_node.set_control_state(false)
	$ShootingSound.play()
	_apply_recoil()
	$Beams/Anim.play("attack")


func _on_HurtBox_body_entered(body: Node) -> void:
	if _parent_node is Global.CLASS_BOT == false:
		return
	if body is Global.CLASS_BOT:
		if body.is_hostile() == _parent_node.is_hostile():
			return
		elif body.is_hostile() != _parent_node.is_hostile() && body.is_alive() == false:
			return
		else:
			body.take_damage(_damage, Vector2(_knockback, 0).rotated(rotation))
	else:
		body.take_damage(_damage, Vector2(_knockback, 0).rotated(rotation))


func _on_Anim_animation_finished(anim_name: String) -> void:
	_parent_node.set_control_state(true)
