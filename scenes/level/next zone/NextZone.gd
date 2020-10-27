extends "res://scenes/level/_base/_BaseAccess.gd"


signal scene_changed
var _entered: bool = false


func _ready() -> void:
	$NextZoneName.global_rotation = 0
	$NextZoneName/Label.text = "To " + name


func _process(_delta: float) -> void:
	if global_position.distance_to(get_global_mouse_position()) <= 150:
		$NextZoneName.visible = true
	else:
		$NextZoneName.visible = false


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER == true && _entered == false:
		emit_signal("scene_changed")
		_entered = true
