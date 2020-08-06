extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _current_swing: int = 0


func _fire_melee() -> void:
	._fire_melee()
	weap_commit = true
	if _current_swing % 2 == 0:
		$Beam/Anim.play("swing_a")
	else:
		$Beam/Anim.play("swing_b")
	_current_swing += 1
	if _current_swing == 2:
		_current_swing = 0


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
