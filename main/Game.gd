extends Node2D


var _scenes: Dictionary = {
	"Menu": preload("res://main/MenuManager.tscn"),
	"Level": preload("res://main/LevelManager.tscn")
}

var _current_scene = null


func _ready() -> void:
	on_change_scene("Menu")


func on_change_scene(new_scene: String) -> void:
	call_deferred("on_change_scene_deferred", new_scene)


func on_change_scene_deferred(new_scene: String) -> void:
	if _current_scene != null:
		_current_scene.free()
	_current_scene = _scenes[new_scene].instance()
	_current_scene.connect("moved", self, "on_change_scene")
	add_child(_current_scene)
