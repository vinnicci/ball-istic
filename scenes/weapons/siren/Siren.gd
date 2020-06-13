extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	$ShootingSound.play()
	for bot in $CallRange.get_overlapping_bodies():
		if bot == _parent_node:
			continue
		if (bot is Global.CLASS_BOT && _parent_node.current_faction == bot.current_faction &&
			bot.has_node("AI") == true):
			bot.get_node("AI").set_master(_parent_node)
