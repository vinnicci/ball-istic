extends "res://scenes/bots/player/Player.gd"


const DUMMY_A = preload("res://levels proper/0_tutorial/DummyA.gd")


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
			return
	body.take_damage(damage, Vector2(0,0))


func _control_player() -> void:
	if Input.is_action_just_pressed("ui_inventory"):
		return
	._control_player()


const TUT_PROJ: = preload("res://levels proper/0_tutorial/TutBlasterProj.gd")


func _clear_surrounding_proj() -> void:
	var areas: Array = $DischargeRadius.get_overlapping_areas()
	for area in areas:
		if area is Global.CLASS_PROJ:
			if current_faction == area.shooter_faction():
				continue
			if area.has_node("Explosion") == true:
				area.exploded = true
			if area is TUT_PROJ:
				area.emit_signal("cleared")
			area.stop_projectile()
