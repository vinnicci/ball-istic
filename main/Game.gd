extends Node2D


var _scenes: Dictionary = {
	"Menu": preload("res://main/MenuManager.tscn"),
	"Level": preload("res://main/LevelManager.tscn")
}
var _current_scene = null
var _current_save_slot: int


func _ready() -> void:
	_init_save_files()
	on_change_scene("Menu")


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


func on_change_scene(new_scene: String, slot_num = -1, slot_name = "") -> void:
	call_deferred("on_change_scene_deferred", new_scene, slot_num, slot_name)


func on_change_scene_deferred(new_scene: String, slot_num, slot_name) -> void:
	if _current_scene != null:
		_current_scene.free()
	_current_scene = _scenes[new_scene].instance()
	if new_scene == "Level" && slot_num != -1:
		_current_scene.current_save_slot = slot_num
		_current_scene.current_save_name = slot_name
	_current_scene.connect("moved", self, "on_change_scene")
	add_child(_current_scene)
