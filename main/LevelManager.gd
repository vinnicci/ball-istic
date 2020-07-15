extends Node


var scenes: Dictionary = {
	"PlayerTut": load("res://test_folder/test level/tutorial level/PlayerTut.tscn"),
	"Player": load("res://scenes/bots/player/Player.tscn"),
	"TutorialLevel": load("res://test_folder/test level/tutorial level/TutorialLevel.tscn"),
	"Level1": load("res://test_folder/test level/level 1/Level1.tscn"),
	"Checkpoint1-2": load("res://test_folder/test level/checkpoint 1-2/Checkpoint1-2.tscn"),
	"BigGuyAssist": load("res://test_folder/test level/big guy assist/BigGuyAssist.tscn")
}
var _saved_player_items: Dictionary = {
	"Items": [],
	"Weapons": [],
	"Passives": []
}
var _saved_respawn_point = null
var _saved_depot_items: Dictionary = {} #key: name, value: arr_items
var _saved_vault_items: Array = [
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null,
	null, null, null, null, null
]
var _saved_big_bots: Dictionary = {} #key: name, value: is_alive

var _player_tut = null
var _player = null
var _current_scene = null


func _ready() -> void:
	randomize()
	on_change_scene("TutorialLevel", "PlayerPos1")


func on_change_scene(new_lvl: String, pos: String) -> void:
	call_deferred("on_change_scene_deferred", new_lvl, pos)


#coroutine resume signal
signal resume


func on_change_scene_deferred(new_lvl: String, pos: String) -> void:
	if _current_scene != null:
		$Resume.start()
		$Anim.play("transition")
		yield(self, "resume")
		if _current_scene.get_node("Bots").get_children().has(_player):
			_player.get_parent().remove_child(_player)
		_save_depot_items(_current_scene)
		_current_scene.queue_free()
	var player
	match new_lvl:
		"TutorialLevel":
			if _player_tut == null:
				_player_tut = scenes["PlayerTut"].instance()
			player = _player_tut
		_:
			if _player == null:
				_player = scenes["Player"].instance()
				_load_player_items()
				_clear_loaded_items()
			if !_player.is_connected("dead", self, "_on_player_dead"):
				_player.connect("dead", self, "_on_player_dead")
			player = _player
	_current_scene = scenes[new_lvl].instance()
	_connect_access(_current_scene)
	_connect_big_bots(_current_scene)
	_load_depot_items(_current_scene)
	_current_scene.connect("moved", self, "on_change_scene")
	_current_scene.get_node("Bots").add_child(player)
	player.position = _current_scene.get_node("Access/" + pos as String).position
	add_child(_current_scene)
	_transition_persistent_data(player)


func _connect_access(lvl: Node) -> void:
	for access in lvl.get_node("Access").get_children():
		match access.get_script():
			Global.BOT_STATION:
				access.connect("autosaved", self, "_on_autosave", [lvl.name, access.name])
			Global.VAULT:
				access.arr_vault = _saved_vault_items


func _on_autosave(lvl, pos) -> void:
	_saved_respawn_point = {}
	_saved_respawn_point["Level"] = lvl
	_saved_respawn_point["Pos"] = pos
	for bot_data in _temp_big_bots.keys():
		_saved_big_bots[bot_data] = _temp_big_bots[bot_data]


func _connect_big_bots(lvl: Node) -> void:
	for bot in lvl.get_node("Bots").get_children():
		if bot.get_bot_radius() > 32:
			var bot_name = lvl.name + bot.name
			if _saved_big_bots.keys().has(bot_name) == false:
				_saved_big_bots[bot_name] = true
			elif (_saved_big_bots.keys().has(bot_name) &&
				_saved_big_bots[bot_name] == false):
				bot.queue_free()
				continue
			bot.connect("dead", self, "_on_big_bot_dead", [lvl.name, bot.name])


var _temp_big_bots: Dictionary


func _on_big_bot_dead(lvl, bot) -> void:
	_temp_big_bots[lvl + bot] = false
	$Anim.play("big_bot_destroyed")


func _save_depot_items(lvl) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is Global.DEPOT:
			var depot_name = lvl.name + access.name
			#save as array
			_saved_depot_items[depot_name] = access.get_node("Items").get_children()
			#remove as nodes
			for item in _saved_depot_items[depot_name]:
				item.get_parent().remove_child(item)


func _load_depot_items(lvl) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is Global.DEPOT:
			var depot_name = lvl.name + access.name
			if _saved_depot_items.keys().has(depot_name) == false:
				continue
			#remove as node
			for item in access.get_node("Items").get_children():
				item.free()
			#add as node
			for item in _saved_depot_items[depot_name]:
				access.get_node("Items").add_child(item)


func _transition_persistent_data(player) -> void:
	#charge cooldown transfer
	var player_charge_time: float = player.get_node("Timers/ChargeCooldown").time_left
	if player_charge_time > 0:
		player.update_bar_charge_level(player_charge_time)


func _save_player_items() -> void:
	#save as array
	for key in _saved_player_items.keys():
		_saved_player_items[key].clear()
		_saved_player_items[key].append(_player.get_node(key).get_children())
	#remove as nodes
	for key in _saved_player_items.keys():
		for arr_item in _saved_player_items[key]:
			for item in arr_item:
				item.get_parent().remove_child(item)


func _load_player_items() -> void:
	for key in _saved_player_items.keys():
		for arr_item in _saved_player_items[key]:
			var i = -1
			for item in arr_item:
				i += 1
				if item is Global.PLAYER_BUILT_IN_WEAP == true:
					continue
				#add as node
				_player.get_node(key).add_child(item)
				#add as ref
				match key:
					"Items": _player.arr_items[i] = item
					"Weapons": _player.arr_weapons[i] = item
					"Passives": _player.arr_passives[i] = item


func _clear_loaded_items() -> void:
	#player items
	for arr in _saved_player_items.keys():
		_saved_player_items[arr] = []


func _save_vault_items() -> void:
	var i = 0
	for item in _saved_vault_items:
		if item != null:
			#save as ref
			_saved_vault_items[i] = item
		i += 1


func _on_Resume_timeout() -> void:
	emit_signal("resume")


func _on_player_dead() -> void:
	_save_player_items()
	_save_vault_items()
	_save_depot_items(_current_scene)
	_temp_big_bots = {}
	$RespawnTimer.start()
	$Anim.play("destroyed")


func _on_RespawnTimer_timeout() -> void:
	var current_scene_name = _current_scene.name
	_current_scene.queue_free()
	_current_scene = null
	if _saved_respawn_point == null:
		on_change_scene("TutorialLevel", "PlayerPos1")
	else:
		on_change_scene(_saved_respawn_point["Level"], _saved_respawn_point["Pos"])
