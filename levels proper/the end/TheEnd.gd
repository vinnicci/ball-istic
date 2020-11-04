extends "res://scenes/level/_base/_BaseLevel.gd"


var _secrets_found: Array
var _lvl_mngr: Node
signal quit_to_menu


func _ready() -> void:
	$AnimationPlayer.queue("0")
	$AnimationPlayer.queue("1")
	$AnimationPlayer.queue("2")
	$AnimationPlayer.queue("3")


func set_quest(secrets_found: Array) -> void:
	_secrets_found = secrets_found


func set_parent(lvl_mngr: Node) -> void:
	_lvl_mngr = lvl_mngr


func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
	match anim_name:
		"3": $CanvasLayer/Label.text = ("Thank you for playing.\nHidden Areas Discovered: %s/12" %
			_secrets_found.size())


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"3": _lvl_mngr.emit_signal("scene_changed", "Menu")
