extends Node


var scenes: Dictionary = {
	"PlayerTut": preload("res://test_folder/test level/tutorial level/PlayerTut.tscn"),
	"Player": preload("res://scenes/bots/player/Player.tscn"),
	"TutorialLevel": preload("res://test_folder/test level/tutorial level/TutorialLevel.tscn"),
	"Level1": preload("res://test_folder/test level/level 1/Level1.tscn"),
	"Checkpoint1-2": preload("res://test_folder/test level/checkpoint 1-2/Checkpoint1-2.tscn"),
	"BigGuyAssist": preload("res://test_folder/test level/big guy assist/BigGuyAssist.tscn")
}
var _saved_player: Dictionary = {
	"Items": [],
	"Weapons": [],
	"Passives": [],
	"Spawn": null #value -> Lvl: level name, Pos: level coords
}
var _saved_big_bots: Dictionary = {} #key: name, value: is_alive
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

#var _proj_pool: Dictionary = {}
var _player_tut = null
var _player = null
var _current_scene = null
signal moved


func _ready() -> void:
	randomize()
	$CanvasLayer/InGameMenu.set_parent(self)
	on_change_scene("TutorialLevel", "Pos1")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		$CanvasLayer/InGameMenu.visible = true
		$CanvasLayer/ColorRect3.visible = true
		get_tree().paused = true


func on_change_scene(new_lvl: String, pos: String) -> void:
	$Resume.start()
	$Anim.play("transition")
	yield(self, "resume")
	if _current_scene != null:
		if _current_scene.get_node("Bots").get_children().has(_player):
			_player.get_parent().remove_child(_player)
		_save_depot_items(_current_scene)
		_save_big_bots()
	call_deferred("on_change_scene_deferred", new_lvl, pos)


#coroutine resume signal
signal resume


func on_change_scene_deferred(new_lvl: String, pos: String) -> void:
	if _current_scene != null:
		_current_scene.free()
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
			if !_player.is_connected("dead", self, "_on_player_dead"):
				_player.connect("dead", self, "_on_player_dead")
			player = _player
	_current_scene = scenes[new_lvl].instance()
	_connect_access(_current_scene)
	_connect_big_bots(_current_scene)
	_load_depot_items(_current_scene)
	_current_scene.get_node("Bots").add_child(player)
	player.position = _current_scene.get_node("Access/" + pos as String).position
	add_child(_current_scene)
#	_pool_proj()
	_transition_persistent_data(player)


#func _pool_proj() -> void:
#	for bot in _current_scene.valid_bots:
#		for weap in bot.get_node("Weapons").get_children():
#			var proj = weap.Projectile
#			var proj_script = proj.get_script()
#			if _proj_pool.keys().has(proj_script) == true:
#				return
#			match proj_script:
#				Global.CLASS_PROJ:
#					_proj_pool[proj_script] = []
#					for i in range(50):
#						_proj_pool[proj_script].append(proj.instance())
#				Global.CLASS_BOT_PROJ:
#					var drone_weap = proj.get_node("Weapons").get_child(0)
#					if drone_weap != null:
#						var drone_proj = drone_weap.Projectile
#						var drone_proj_script = drone_proj.get_script()
#						if _proj_pool.keys().has(drone_proj_script) == true:
#							return
#						_proj_pool[drone_proj_script] = []
#						for i in range(50):
#							_proj_pool[drone_proj_script].append(proj.instance())


func _connect_access(lvl: Node) -> void:
	for access in lvl.get_node("Access").get_children():
		match access.get_script():
			Global.BOT_STATION:
				access.connect("autosaved", self, "_on_autosave", [lvl.name, access.name])
			Global.VAULT:
				access.arr_vault = _saved_vault_items
			Global.NEXT_ZONE:
				access.connect("moved", self, "on_change_scene")


func _on_autosave(lvl, pos) -> void:
	_saved_player["Spawn"] = {}
	_saved_player["Spawn"]["Lvl"] = lvl
	_saved_player["Spawn"]["Pos"] = pos


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


var _temp_big_bots: Dictionary = {}


func _on_big_bot_dead(lvl, bot) -> void:
	_temp_big_bots[lvl + bot] = false
	$Anim.play("big_bot_destroyed")


func _save_big_bots() -> void:
	for key in _temp_big_bots.keys():
		_saved_big_bots[key] = _temp_big_bots[key]
	_temp_big_bots = {}


func _on_Anim_animation_finished(anim_name: String) -> void:
	if anim_name == "big_bot_destroyed":
		Engine.time_scale = 1.0


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
			access.get_node("Items").free()
			#add as node
			var item_node = Node2D.new()
			item_node.name = "Items"
			for item in _saved_depot_items[depot_name]:
				item_node.add_child(item)
			access.add_child(item_node)
			#clear saved
			_saved_depot_items[depot_name].clear()


func _transition_persistent_data(player) -> void:
	#basically resume charge cooldown's interrupted anim
	var player_charge_time: float = player.get_node("Timers/ChargeCooldown").time_left
	if player_charge_time > 0:
		player.update_bar_charge_level(player_charge_time)


func _save_player_items() -> void:
	#save as array
	var keys = ["Items", "Weapons", "Passives"]
	for key in keys:
		_saved_player[key] = _player.get_node(key).get_children()
	#detach items
	var clone = null
	for key in keys:
		for item in _saved_player[key]:
			if item == _player.current_weapon:
				clone = item.duplicate()
				continue
			item.get_parent().remove_child(item)
	if clone != null:
		_saved_player["Weapons"].push_front(clone)


func _load_player_items() -> void:
	var keys = ["Items", "Weapons", "Passives"]
	for key in keys:
		for item in _saved_player[key]:
			if item is Global.PLAYER_BUILT_IN_WEAP == true:
				continue
			#add as node
			if item != null:
				_player.get_node(key).add_child(item)
	#clear saved player items
	for arr in keys:
		_saved_player[arr].clear()


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
	$CanvasLayer/ColorRect2.modulate.a = 0
	_temp_big_bots = {}
	_save_player_items()
	_save_vault_items()
	_save_depot_items(_current_scene)
	$RespawnTimer.start()
	$Anim.play("destroyed")


func _on_RespawnTimer_timeout() -> void:
	_current_scene.queue_free()
	_current_scene = null
	if _saved_player["Spawn"] == null:
		on_change_scene("TutorialLevel", "Pos1")
	else:
		on_change_scene(_saved_player["Spawn"]["Lvl"],
			_saved_player["Spawn"]["Pos"])
