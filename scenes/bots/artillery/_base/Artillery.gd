extends "res://scenes/bots/_base/_BaseBot.gd"


func _on_Shoot_timeout() -> void:
	if rand_range(0, 1) <= 0.5:
		shoot_weapon()


func set_controller(bot: Node) -> void:
	bot.get_node("AI").set_master(self)
	bot.connect("dead", self, "_on_controller_dead")


func _on_controller_dead() -> void:
	$Timers/Shoot.stop()
