extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _player_cam: Camera2D
var _level_cam: Camera2D
const DIST_SHAKE: int = 3000
const SHAKE: int = 15


func _fire_other() -> void:
	$ShootingSound.play()
	if is_instance_valid(_player_cam) == false:
		_player_cam = _level_node.get_player().get_node("Camera2D")
	if is_instance_valid(_level_cam) == false:
		_level_cam = _level_node.get_node("Camera2D")
	if is_instance_valid(_player_cam) && (_player_cam.get_parent().state != Global.CLASS_BOT.State.DEAD &&
		global_position.distance_to(_player_cam.global_position) < DIST_SHAKE):
		_player_cam.shake_camera(SHAKE, 0.05, 0.05, 1)
	elif global_position.distance_to(_level_cam.global_position) < DIST_SHAKE:
		_level_cam.shake_camera(SHAKE, 0.1, 0.1, 1)
