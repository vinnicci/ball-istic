extends Node2D


var _scenes: Dictionary = {
	"Menu": preload("res://scenes/main/MenuManager.tscn"),
	"Level": preload("res://levels proper/main/LevelManagerDemo.tscn")
}
var _current_scene
var _current_save_slot: int


func _ready() -> void:
	_init_save_files()
	_on_scene_changed("Menu")


func _init_save_files() -> void:
	var save_dir: String = "user://saves/"
	var dir: Directory = Directory.new()
	if dir.dir_exists(save_dir) == false:
		dir.make_dir_recursive(save_dir)
	for i in range(5):
		var save_file: String = save_dir + "save_" + str(i) + ".tres"
		if dir.file_exists(save_file) == true:
			continue
		var save: Resource = Global.CLASS_SAVE.new()
		ResourceSaver.save(save_file, save)


func _on_scene_changed(new_scene: String, slot_num = -1, slot_name = "") -> void:
	call_deferred("_on_scene_changed_deferred", new_scene, slot_num, slot_name)


func _on_scene_changed_deferred(new_scene: String, slot_num, slot_name) -> void:
	if is_instance_valid(_current_scene) == true:
		_current_scene.free()
	_current_scene = _scenes[new_scene].instance()
	if new_scene == "Level" && slot_num != -1:
		_current_scene.current_save_slot = slot_num
		_current_scene.current_save_name = slot_name
	_current_scene.connect("scene_changed", self, "_on_scene_changed")
	add_child(_current_scene)
