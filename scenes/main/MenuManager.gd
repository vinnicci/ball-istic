extends Node


var _current_scene: String = ""
signal scene_changed


func _ready() -> void:
	for scene in get_children():
		if scene.is_in_group("Scene"):
			scene.connect("scene_changed", self, "_on_scene_changed")
	_on_scene_changed("MainMenu")


func _on_scene_changed(new_scene: String, slot_num = -1, slot_name = "") -> void:
	if new_scene == "Play":
		emit_signal("scene_changed", "Level", slot_num, slot_name)
		return
	if _current_scene != "":
		get_node(_current_scene).visible = false
	$Resume.start()
	$Anim.play("transition")
	yield(self, "resume")
	_current_scene = new_scene
	get_node(_current_scene).visible = true


signal resume


#coroutine resume signal
func _on_Resume_timeout() -> void:
	emit_signal("resume")
