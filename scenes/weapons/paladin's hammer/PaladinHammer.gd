extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _process(delta: float) -> void:
	if _parent_node is Global.CLASS_BOT && _parent_node.state == Global.CLASS_BOT.State.DEAD:
		$Hammer/HurtBox.monitoring = false
		$Hammer.hide()


func _fire_melee() -> void:
	._fire_melee()
	weap_commit = true
	$Hammer/Anim.play("swing")


#also stops projectiles
func _on_HurtBox_area_entered(area: Area2D) -> void:
	if area is Global.CLASS_PROJ:
		if _parent_node.current_faction == area.shooter_faction():
			return
		level_node.despawn_projectile(area)


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
