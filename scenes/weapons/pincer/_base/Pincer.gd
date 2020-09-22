extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _process(delta: float) -> void:
	if _parent_node is Global.CLASS_BOT && _parent_node.state == Global.CLASS_BOT.State.DEAD:
		$Beams/Beam1/HurtBox.monitoring = false
		$Beams/Beam2/HurtBox.monitoring = false
		$Beams.hide()


func _fire_melee() -> void:
	._fire_melee()
	weap_commit = true
	$Beams/Anim.play("attack")


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
