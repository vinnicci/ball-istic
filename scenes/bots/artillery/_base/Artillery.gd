extends "res://scenes/bots/_base/_BaseBot.gd"


var deg_rand: Array = [-5, 5, -10, 10, 0]
var _controller: Node


func _on_Shoot_timeout() -> void:
	if is_instance_valid(_controller) == false:
		$Timers/Shoot.stop()
		return
	if rand_range(0, 1) <= 0.5:
		shoot_weapon()
	deg_rand.shuffle()
	_switch_tween.interpolate_property(current_weapon, "rotation", current_weapon.rotation,
		deg2rad(deg_rand.front()), 2.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_switch_tween.start()


func set_controller(bot: Node) -> void:
	if is_instance_valid(bot) == false:
		return
	_controller = bot
	bot.get_node("AI").set_master(self)
