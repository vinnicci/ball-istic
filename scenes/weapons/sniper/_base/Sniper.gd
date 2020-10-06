extends "res://scenes/weapons/_base/_BaseWeapon.gd"


const ZOOMED_OUT: = Vector2(2.25, 2.25)
const ZOOMED_NORM: = Vector2(1.5, 1.5)
var _camera: Camera2D


func set_parent(new_parent) -> void:
	.set_parent(new_parent)
	if new_parent is Global.CLASS_PLAYER:
		_camera = _parent_node.get_node("Camera2D")


#camera zoom effect
func _process(delta: float) -> void:
	if _parent_node is Global.CLASS_PLAYER:
		if (_parent_node.current_weapon == self &&
			(_parent_node.state == Global.CLASS_BOT.State.TURRET ||
			_parent_node.state == Global.CLASS_BOT.State.TO_TURRET) &&
			_camera.zoom == ZOOMED_NORM):
			_animate_zoom(true)
		elif ((_parent_node.current_weapon != self ||
			(_parent_node.state != Global.CLASS_BOT.State.TURRET &&
			_parent_node.state != Global.CLASS_BOT.State.TO_TURRET)) &&
			_camera.zoom == ZOOMED_OUT):
			_animate_zoom(false)


func _animate_zoom(zoom: bool) -> void:
	var zoom_val: Vector2
	if zoom == true:
		zoom_val = ZOOMED_OUT
	else:
		zoom_val = ZOOMED_NORM
	var tween = $WeaponTween
	tween.interpolate_property(_camera, "zoom", _camera.zoom, zoom_val, 0.5, Tween.TRANS_SINE,
		Tween.EASE_IN_OUT)
	tween.start()
