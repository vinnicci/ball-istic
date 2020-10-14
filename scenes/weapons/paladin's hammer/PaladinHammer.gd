extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _process(delta: float) -> void:
	if _parent_node is Global.CLASS_BOT && _parent_node.state == Global.CLASS_BOT.State.DEAD:
		$Hammer/HurtBox.monitoring = false
		$Hammer.hide()


func _fire_melee() -> void:
	._fire_melee()
	weap_commit = true
	$Hammer/Anim.play("swing")


func _apply_melee_crit_effect(body) -> void:
	body.stun_effect(melee_crit_stun_time)


#also stop projectiles
func _on_HurtBox_area_entered(area: Area2D) -> void:
	if area is Global.CLASS_PROJ:
		if _parent_node.current_faction == area.shooter_faction():
			return
		if area.has_node("Explosion") == true:
			area.get_node("Explosion").exploded = true
		area.stop_projectile()


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
