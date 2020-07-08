extends Node


var scenes: Dictionary = {
	"tut": load("res://main/tutorial level/TutorialLevel.tscn"),
	"lvl_1": load("res://main/level 1/Level1.tscn"),
	"cp_12": load("res://main/checkpoint 1-2/Checkpoint1-2.tscn")
}
var _player_tut = preload("res://main/tutorial level/PlayerTut.tscn")
var _player = preload("res://scenes/bots/player/Player.tscn")
var _current_scene = null


func _ready() -> void:
	_current_scene = scenes["tut"].instance()
	_current_scene.connect("moved", self, "on_change_scene")
	var player = _player_tut.instance()
	_current_scene.get_node("Bots").add_child(player)
	player.position = _current_scene.get_node("PlayerPos1").position
	add_child(_current_scene)


func on_change_scene(level: String, pos: String) -> void:
	call_deferred("on_change_scene_deferred", level, pos)


func on_change_scene_deferred(level: String, pos: String) -> void:
	_current_scene.queue_free()
	_current_scene = scenes[level].instance()
	_current_scene.connect("moved", self, "on_change_scene")
	var player
	if level == "tut":
		player = _player_tut.instance()
	else:
		player = _player.instance()
	_current_scene.get_node("Bots").add_child(player)
	player.position = _current_scene.get_node(pos).position
	add_child(_current_scene)
