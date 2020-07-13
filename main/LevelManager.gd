extends Node


var scenes: Dictionary = {
	"tut": load("res://test_folder/test level/tutorial level/TutorialLevel.tscn"),
	"lvl_1": load("res://test_folder/test level/level 1/Level1.tscn"),
	"cp_12": load("res://test_folder/test level/checkpoint 1-2/Checkpoint1-2.tscn"),
	"end": load("res://test_folder/test level/big guy assist/BigGuyAssist.tscn")
}
var _player_tut = preload("res://test_folder/test level/tutorial level/PlayerTut.tscn")
var _player = preload("res://scenes/bots/player/Player.tscn")
var _current_scene = null


func _ready() -> void:
	randomize()
	on_change_scene("tut", "PlayerPos1")


func on_change_scene(level: String, pos: String) -> void:
	call_deferred("on_change_scene_deferred", level, pos)


func on_change_scene_deferred(level: String, pos: String) -> void:
	$TransitionTimer.start()
	$Anim.play("transition")
	if _current_scene != null:
		_current_scene.queue_free()
	_current_scene = scenes[level].instance()
	_current_scene.connect("moved", self, "on_change_scene")
	var player
	if level == "tut":
		player = _player_tut.instance()
	else:
		player = _player.instance()
		player.connect("dead", self, "_on_player_dead")
	_current_scene.get_node("Bots").add_child(player)
	player.position = _current_scene.get_node(pos).position


func _on_TransitionTimer_timeout() -> void:
	add_child(_current_scene)


func _on_player_dead() -> void:
	$RespawnTimer.start()
	$Anim.play("destroyed")


func _on_RespawnTimer_timeout() -> void:
	on_change_scene("tut", "PlayerPos1")
