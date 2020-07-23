extends Node


var _current_scene: String = ""
signal moved


func _ready() -> void:
	for scene in get_children():
		if scene.is_in_group("Scene"):
			scene.connect("moved", self, "on_change_scene")
	on_change_scene("MainMenu")


func on_change_scene(new_scene: String, slot_num = -1, slot_name = "") -> void:
	if new_scene == "Play":
		emit_signal("moved", "Level", slot_num, slot_name)
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
