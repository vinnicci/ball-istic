extends Node


var scenes: Dictionary = {
	"PlayerTut": preload("res://scenes/main/levels proper/0_tutorial/PlayerTut.tscn"),
	"Player": preload("res://scenes/bots/player/Player.tscn"),
	"Tutorial": preload("res://scenes/main/levels proper/0_tutorial/Tutorial.tscn"),
	"Area1-1": preload("res://scenes/main/levels proper/1-1_area/Area1-1.tscn"),
	"Secret1-1": preload("res://scenes/main/levels proper/1-1_secret/Secret1-1.tscn"),
	"Checkpoint1-1": preload("res://scenes/main/levels proper/1-1_checkpoint/Checkpoint1-1.tscn"),
	"Area1-2": preload("res://scenes/main/levels proper/1-2_area/Area1-2.tscn"),
	"Hub": preload("res://scenes/main/levels proper/0_hub/Hub.tscn")
}
var _saved_player: Dictionary = {
	"Items": [],
	"Weapons": [],
	"Passives": [],
	"Spawn": {} #value -> Lvl: lvl name, Pos: level coords
}
var _saved_big_bots: Dictionary #key: lvl name + bot name, value: is_alive
var _saved_depot_items: Dictionary #key: lvl name + depot name, value: arr_items
var _saved_vault_items: Array #store item filename
var _saved_paths: Array #store lvl name + destructible name
var current_save_slot: int
var current_save_name: String

var _player_tut = null
var _player = null
var _current_scene = null
const SAVE_DIR: String = "user://saves/"
signal moved


func _ready() -> void:
	randomize()
	$CanvasLayer/InGameMenu.set_parent(self)
	_load_from_disk()
	_load_player_spawn()


func _load_from_disk() -> void:
	var dir = Directory.new()
	var save_file
	if dir.file_exists(SAVE_DIR + "save_" + str(current_save_slot) + ".tres") == true:
		save_file = load(SAVE_DIR + "save_" + str(current_save_slot) + ".tres")
	else:
		push_error("Save file doesn't exist.")
		return
	if _verify_data(save_file) == false:
		push_error("Save file can't be verified.")
		return
	_saved_player = save_file.player
	_saved_big_bots = save_file.big_bots
	_saved_depot_items = save_file.depot_items
	_saved_vault_items = save_file.vault_items
	_saved_paths = save_file.paths


func _verify_data(save_file) -> bool:
	var save_data = ["save_name", "player", "big_bots", "depot_items", "vault_items"]
	for data in save_data:
		if save_file.get(data) == null:
			return false
	return true


func save_to_disk() -> void:
	_save_player_items()
	_save_depot_items(_current_scene)
	_save_vault_items(_current_scene)
	var new_save = Global.CLASS_SAVE.new()
	new_save.save_name = current_save_name
	new_save.player = _saved_player
	new_save.big_bots = _saved_big_bots
	new_save.depot_items = _saved_depot_items
	new_save.vault_items = _saved_vault_items
	new_save.paths = _saved_paths
	ResourceSaver.save(SAVE_DIR + "save_" + str(current_save_slot) + ".tres",
		new_save)


func _on_LevelManager_tree_exiting() -> void:
	stop_player(true)
	save_to_disk()


var _reset_inv_visibility: bool = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if is_instance_valid(_player) && _player.ui_inventory.visible == true:
			_player.ui_inventory.visible = false
			_player.held_item.visible = false
			_reset_inv_visibility = true
		$CanvasLayer/InGameMenu.visible = true
		$CanvasLayer/ColorRect3.visible = true
		get_tree().paused = true
		return
	if is_instance_valid(_player) && _reset_inv_visibility == true:
		_player.ui_inventory.visible = true
		_player.held_item.visible = true
		_reset_inv_visibility = false


func on_change_scene(new_lvl: String, pos: String) -> void:
	$Resume.start()
	$Anim.play("transition")
	yield(self, "resume")
	if _current_scene != null:
		if _current_scene.get_node("Bots").get_children().has(_player):
			_player.get_parent().remove_child(_player)
		_save_depot_items(_current_scene)
		_save_vault_items(_current_scene)
		_save_big_bots()
	call_deferred("on_change_scene_deferred", new_lvl, pos)


func on_change_scene_deferred(new_lvl: String, pos: String) -> void:
	if _current_scene != null:
		_current_scene.free()
	var player
	if new_lvl == "Tutorial":
		if _player_tut == null:
			_player_tut = scenes["PlayerTut"].instance()
		player = _player_tut
	else:
		if _player == null:
			_player = scenes["Player"].instance()
			_load_player_items()
		if !_player.is_connected("dead", self, "_on_player_dead"):
			_player.connect("dead", self, "_on_player_dead")
		player = _player
		_player.get_node("Name/Label").text = current_save_name
	_current_scene = scenes[new_lvl].instance()
	$CanvasLayer/AreaName.text = _current_scene.disp_name
	_current_scene.connect("secret_found", self, "on_secret_found")
	_connect_access(_current_scene)
	_connect_big_bots(_current_scene)
	_load_depot_items(_current_scene)
	_load_vault_items(_current_scene)
	_current_scene.get_node("Bots").add_child(player)
	player.position = _current_scene.get_node("Access/" + str(pos)).position
	add_child(_current_scene)
	_load_saved_paths(_current_scene)
	_resume(player)


func _connect_access(lvl: Node) -> void:
	for access in lvl.get_node("Access").get_children():
		match access.get_script():
			Global.BOT_STATION:
				access.connect("autosaved", self, "_save_player_spawn",
					[lvl.name, access.name])
			Global.NEXT_ZONE:
				access.connect("moved", self, "on_change_scene")


func _connect_big_bots(lvl: Node) -> void:
	for bot in lvl.get_node("Bots").get_children():
		if bot.respawnable == false:
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
	if (is_instance_valid(_player) == false ||
		_player.state == Global.CLASS_BOT.State.DEAD):
		return
	_temp_big_bots[lvl + bot] = false
	$Anim.play("big_bot_destroyed")


func _save_big_bots() -> void:
	for key in _temp_big_bots.keys():
		_saved_big_bots[key] = _temp_big_bots[key]
	_temp_big_bots = {}


func _on_Anim_animation_finished(anim_name: String) -> void:
	match anim_name:
		"transition":
			$Anim.play("new_area")


func _resume(player) -> void:
	#resume interrupted charge cooldown
	var player_charge_time: float = player.get_node("Timers/ChargeCooldown").time_left
	if player_charge_time > 0:
		player.update_bar_charge_level(player_charge_time)


#############
# depot items
#############
func _save_depot_items(lvl) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is Global.DEPOT:
			var depot_name = lvl.name + access.name
			var depot_items = access.get_node("Items").get_children()
			#save as array
			if _saved_depot_items.keys().has(depot_name) == false:
				_saved_depot_items[depot_name] = []
			for item in depot_items:
				_saved_depot_items[depot_name].append(item.filename)
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
			for item_path in _saved_depot_items[depot_name]:
				item_node.add_child(load(item_path).instance())
			access.add_child(item_node)
			#clear saved
			_saved_depot_items[depot_name].clear()


##############
# player items
##############
func _save_player_items() -> void:
	if is_instance_valid(_player) == false:
		return
	#clear player trash
	var trash_slot = _player.ui_inventory.get_node("AllItems/SlotsContainer/HBoxContainer/TrashSlot")
	if trash_slot.item != null:
		trash_slot.free()
	#save as array
	var keys = ["Items", "Weapons", "Passives"]
	var items: Dictionary = {}
	for key in keys:
		items[key] = _player.get_node(key).get_children()
	#detach items
	var clone = null
	for key in keys:
		for item in items[key]:
			_saved_player[key].append(item.filename)
			#cloning because the weapon becomes invisible as soon as the
			#weapon gets removed as a child
			if item == _player.current_weapon:
				clone = item.duplicate()
				_player.get_node("Weapons").add_child(clone)
			item.get_parent().remove_child(item)


func _load_player_items() -> void:
	var keys = ["Items", "Weapons", "Passives"]
	for key in keys:
		for item_path in _saved_player[key]:
			var item = load(item_path).instance()
			if item is Global.PLAYER_BUILT_IN_WEAP:
				continue
			#add as node
			_player.get_node(key).add_child(item)
	#clear saved player items
	for arr in keys:
		_saved_player[arr].clear()


###############
# player spawn
###############
func _save_player_spawn(lvl: String, pos: String) -> void:
	_saved_player["Spawn"] = {}
	_saved_player["Spawn"]["Lvl"] = lvl
	_saved_player["Spawn"]["Pos"] = pos


func _load_player_spawn() -> void:
	if _saved_player["Spawn"] == null:
		on_change_scene("Tutorial", "Pos1")
	else:
		on_change_scene(_saved_player["Spawn"]["Lvl"], _saved_player["Spawn"]["Pos"])


#############
# vault items
#############
func _save_vault_items(lvl) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is Global.VAULT:
			var vault_items = access.get_node("Items").get_children()
			for item in vault_items:
				_saved_vault_items.append(item.filename)
				item.get_parent().remove_child(item)


func _load_vault_items(lvl) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is Global.VAULT:
			for i in _saved_vault_items.size():
				var item = load(_saved_vault_items[i]).instance()
				access.get_node("Items").add_child(item)
			_saved_vault_items.clear()


##############
# secret paths
##############
func on_secret_found(lvl: Node, destructible: Node) -> void:
	var path_name: String = lvl.name + destructible.name
	if _saved_paths.has(path_name) == false:
		_saved_paths.append(path_name)


func _load_saved_paths(lvl: Node) -> void:
	for nav_node in lvl.get_node("Nav").get_children():
		if nav_node is TileMap:
			var path_name: String = lvl.name + nav_node.name
			if _saved_paths.has(path_name) == true:
				nav_node.destroy()


#coroutine resume signal
signal resume


func _on_Resume_timeout() -> void:
	emit_signal("resume")


func _on_player_dead() -> void:
	$CanvasLayer/ColorRect2.modulate.a = 0
	_temp_big_bots = {}
	_save_player_items()
	_save_vault_items(_current_scene)
	_save_depot_items(_current_scene)
	$RespawnTimer.start()
	$Anim.play("destroyed")


#this func exists to stop get_global_mouse_pos error whenever the
#mouse cursor gets out of the current scene tree on transition
func stop_player(stop: bool) -> void:
	if is_instance_valid(_player) == true:
		_player.stopped = stop
	if is_instance_valid(_player_tut) == true:
		_player_tut.stopped = stop


func _on_RespawnTimer_timeout() -> void:
	_current_scene.queue_free()
	_load_player_spawn()
