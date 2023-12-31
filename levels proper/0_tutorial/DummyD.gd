extends "res://scenes/bots/dummy/Dummy.gd"


signal parried


func _on_Bot_body_entered(body: Node) -> void:
	if state != State.CHARGE_ROLL:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	$CollisionSpark.look_at(body.global_position)
	$Sounds/ChargeAttackHit.play()
	$CollisionSpark.emitting = true
	var damage: float = ((current_speed * 0.125 * current_charge_force_mult) *
		current_charge_dmg_rate)
	if body is Global.CLASS_BOT:
		if current_faction == body.current_faction:
			return
		#if both bots are charging each other
		#or a charging bot hit a parrying bot, damage is reduced to 1%
		if body.state == Global.CLASS_BOT.State.CHARGE_ROLL:
			deflect_effect()
			return
		elif body.get_node("Timers/DischargeParry").is_stopped() == false:
			var dir: float = (global_position - body.global_position).angle()
			apply_knockback(Vector2(1500, 0).rotated(dir))
			deflect_effect()
			if body is Global.CLASS_PLAYER:
				emit_signal("parried")
			return
	body.take_damage(damage, Vector2(0,0))
