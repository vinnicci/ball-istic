extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _deg_increment: = 5


func _charge_fire() -> void:
	if _parent_node.state != Global.CLASS_BOT.State.TURRET:
		return
	weap_commit = true
	$Timers/BurstTimer.start()
	global_rotation += deg2rad(10)


func _on_BurstTimer_timeout() -> void:
	if _current_burst_count == burst_count || _parent_node.state == Global.CLASS_BOT.State.DEAD:
		_current_burst_count = 0
		weap_commit = false
		return
	$ShootingSound.play()
	_fire_auto()
	_apply_recoil()
	global_rotation += deg2rad(_deg_increment)
	if _current_burst_count % 5 == 0:
		_deg_increment *= -1
	_current_burst_count += 1
	$Timers/BurstTimer.start()
