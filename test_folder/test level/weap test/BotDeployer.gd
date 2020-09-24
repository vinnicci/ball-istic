extends Area2D


func _on_BotDeployer_body_entered(body: Node) -> void:
	var parent = get_parent()
	if body is Global.CLASS_PLAYER && parent.state != Global.CLASS_BOT.State.TURRET:
		parent.switch_mode()
