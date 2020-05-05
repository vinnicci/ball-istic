extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _deg_rotate: = 10


func _charge_fire() -> void:
	if _parent_node.is_rolling() == true:
		return
	_is_shooting = true
	$Timers/BurstTimer.start()
	global_rotation += deg2rad(20)


func _on_BurstTimer_timeout() -> void:
	if _current_burst_count == proj_count_per_shot:
		_current_burst_count = 0
		_is_shooting = false
		return
	$ShootingSound.play()
	_spawn_proj()
	_apply_recoil()
	global_rotation += deg2rad(_deg_rotate)
	if _current_burst_count % 5 == 0:
		_deg_rotate *= -1
	_current_burst_count += 1
	$Timers/BurstTimer.start()
