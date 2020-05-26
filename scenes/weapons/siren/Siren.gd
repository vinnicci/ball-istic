extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	$ShootingSound.play()
	$CallCircle/Anim.play("call_circle")
	for bot in $CallRange.get_overlapping_bodies():
		if bot is Global.CLASS_BOT && _parent_node.is_hostile() == bot.is_hostile() && bot.has_node("AI") == true:
			bot.get_node("AI").set_master(_parent_node)
