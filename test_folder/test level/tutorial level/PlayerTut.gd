extends "res://scenes/bots/player/Player.gd"


const DUMMY_A = preload("res://test_folder/test level/tutorial level/DummyA.gd")
const DUMMY_C = preload("res://test_folder/test level/tutorial level/DummyC.gd")


func _ready() -> void:
	faction = Color(0, 1, 0)
	reset_bot_vars()


signal clashed


func _on_Bot_body_entered(body: Node) -> void:
	if state != State.CHARGE_ROLL:
		if $Sounds/Bump.playing == false:
			$Sounds/Bump.play()
		return
	$CollisionSpark.look_at(body.global_position)
	$Sounds/ChargeAttackHit.play()
	$CollisionSpark.emitting = true
	if body is DUMMY_A:
		return
	var damage: float = ((current_speed * 0.125 * current_charge_force_factor) *
		current_charge_damage_rate)
	if body is Global.CLASS_BOT:
		if current_faction == body.current_faction:
			return
		#if both bots are charging each other
		#or a charging bot hit a parrying bot, damage is reduced to 1%
		if body.state == Global.CLASS_BOT.State.CHARGE_ROLL:
			_play_anim(global_position, _deflect_feedback.instance(), "deflect")
			$Sounds/Clash.play()
			if body is DUMMY_C:
				emit_signal("clashed")
			return
		elif body.get_node("Timers/DischargeParry").is_stopped() == false:
			var dir: float = (global_position - body.global_position).angle()
			apply_knockback(Vector2(1500, 0).rotated(dir))
			$Sounds/Clash.play()
			return
	body.take_damage(damage, Vector2(0,0))
	
