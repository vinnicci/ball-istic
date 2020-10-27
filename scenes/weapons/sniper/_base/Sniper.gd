extends "res://scenes/weapons/_base/_BaseWeapon.gd"


const ZOOMED_OUT: = Vector2(2.25, 2.25)
const ZOOMED_NORM: = Vector2(1.5, 1.5)
enum State {
	NONE, ZOOMED_OUT, ZOOMED_NORM
}
var zoom_state = State.NONE
var _camera: Camera2D


func set_parent(new_parent) -> void:
	.set_parent(new_parent)
	if new_parent is Global.CLASS_PLAYER:
		_camera = _parent_node.get_node("Camera2D")


#camera zoom effect
func _process(_delta: float) -> void:
	if _parent_node is Global.CLASS_PLAYER == false:
		zoom_state = State.NONE
		return
	if _parent_node.current_weapon != self:
		_animate_zoom(ZOOMED_NORM)
		zoom_state = State.NONE
		return
	match _camera.zoom:
		ZOOMED_NORM: zoom_state = State.ZOOMED_NORM
		ZOOMED_OUT: zoom_state = State.ZOOMED_OUT
	if (zoom_state == State.ZOOMED_NORM &&
		(_parent_node.state == Global.CLASS_BOT.State.TURRET ||
		_parent_node.state == Global.CLASS_BOT.State.TO_TURRET)):
		_animate_zoom(ZOOMED_OUT)
		zoom_state = State.ZOOMED_OUT
	elif (zoom_state == State.ZOOMED_OUT &&
		(_parent_node.state != Global.CLASS_BOT.State.TURRET &&
		_parent_node.state != Global.CLASS_BOT.State.TO_TURRET)):
		_animate_zoom(ZOOMED_NORM)
		zoom_state = State.ZOOMED_NORM


func _animate_zoom(zoom: Vector2) -> void:
	if zoom_state == State.NONE:
		return
	var tween = $WeaponTween
	tween.interpolate_property(_camera, "zoom", _camera.zoom, zoom, 0.5,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
