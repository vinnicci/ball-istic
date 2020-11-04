extends Node


var scenes: Dictionary = {
	"PlayerTut": preload("res://levels proper/0_tutorial/PlayerTut.tscn"),
	"Player": preload("res://scenes/bots/player/Player.tscn"),
	"Tutorial": preload("res://levels proper/0_tutorial/Tutorial.tscn"),
	"Area1-1": preload("res://levels proper/1-1_area/Area1-1.tscn"),
	"Secret1-1": preload("res://levels proper/1-1_secret/Secret1-1.tscn"),
	"Checkpoint1-1": preload("res://levels proper/1-1_checkpoint/Checkpoint1-1.tscn"),
	"Area1-2": preload("res://levels proper/1-2_area/Area1-2.tscn"),
	"Hub": preload("res://levels proper/0_hub/Hub.tscn"),
	"Area1-3": preload("res://levels proper/1-3_area/Area1-3.tscn"),
	"Area1-4": preload("res://levels proper/1-4_area/Area1-4.tscn"),
	"Secret1-2": preload("res://levels proper/1-2_secret/Secret1-2.tscn"),
	"Checkpoint1-2": preload("res://levels proper/1-2_checkpoint/Checkpoint1-2.tscn"),
	"Area1-5": preload("res://levels proper/1-5_area/Area1-5.tscn"),
	"Area1Final": preload("res://levels proper/1_area_final/Area1Final.tscn"),
	"Secret1-3": preload("res://levels proper/1-3_secret/Secret1-3.tscn"),
	"Secret1-4": preload("res://levels proper/1-4_secret/Secret1-4.tscn"),
	"Area2-1": preload("res://levels proper/2-1_area/Area2-1.tscn"),
	"Area2-2": preload("res://levels proper/2-2_area/Area2-2.tscn"),
	"Area2-3": preload("res://levels proper/2-3_area/Area2-3.tscn"),
	"Checkpoint2-1": preload("res://levels proper/2-1_checkpoint/Checkpoint2-1.tscn"),
	"Secret2-1": preload("res://levels proper/2-1_secret/Secret2-1.tscn"),
	"Area2-4": preload("res://levels proper/2-4_area/Area2-4.tscn"),
	"Checkpoint2-2": preload("res://levels proper/2-2_checkpoint/Checkpoint2-2.tscn"),
	"Secret2-2": preload("res://levels proper/2-2_secret/Secret2-2.tscn"),
	"Area2-5": preload("res://levels proper/2-5_area/Area2-5.tscn"),
	"Area2Final": preload("res://levels proper/2_area_final/Area2Final.tscn"),
	"Secret2-3": preload("res://levels proper/2-3_secret/Secret2-3.tscn"),
	"Secret2-4": preload("res://levels proper/2-4_secret/Secret2-4.tscn"),
	"Area3-1": preload("res://levels proper/3-1_area/Area3-1.tscn"),
	"Secret3-1": preload("res://levels proper/3-1_secret/Secret3-1.tscn"),
	"Area3-2": preload("res://levels proper/3-2_area/Area3-2.tscn"),
	"Area3-3": preload("res://levels proper/3-3_area/Area3-3.tscn"),
	"Checkpoint3-1": preload("res://levels proper/3-1_checkpoint/Checkpoint3-1.tscn"),
	"Area3-4": preload("res://levels proper/3-4_area/Area3-4.tscn"),
	"Secret3-2": preload("res://levels proper/3-2_secret/Secret3-2.tscn"),
	"Checkpoint3-2": preload("res://levels proper/3-2_checkpoint/Checkpoint3-2.tscn"),
	"Area3-5": preload("res://levels proper/3-5_area/Area3-5.tscn"),
	"Area3Final": preload("res://levels proper/3_area_final/Area3Final.tscn"),
	"Secret3-3": preload("res://levels proper/3-3_secret/Secret3-3.tscn"),
	"TheEnd": preload("res://levels proper/the end/TheEnd.tscn")
}
var _saved_player: Dictionary = {
	"Items": [],
	"Weapons": [],
	"Passives": [],
	"Spawn": {} #value -> Lvl: lvl name, Pos: level coords
}
var _saved_quests: Dictionary = {
	"KEYS": [],
	"DACS": []
}
var _saved_despawnable_bots: Dictionary #key: lvl name + bot name, value: is_alive
var _saved_depot_items: Dictionary #key: lvl name + depot name, value: arr_items
var _saved_vault_items: Array #store item filename
var _saved_paths: Array #store lvl name + destructible name
var current_save_slot: int
var current_save_name: String

var _player_tut: Node
var _player: Node
var _current_scene: Node
const SAVE_DIR: String = "user://saves/"
signal scene_changed


func _ready() -> void:
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
	_saved_despawnable_bots = save_file.despawnable_bots
	_saved_depot_items = save_file.depot_items
	_saved_vault_items = save_file.vault_items
	_saved_quests = save_file.quests
	_saved_paths = save_file.paths


const SAVE_DATA: Array = [
	"save_name", "player", "quests", "despawnable_bots", "depot_items",
	"vault_items", "paths"
]


func _verify_data(save_file) -> bool:
	var save_data = SAVE_DATA
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
	new_save.despawnable_bots = _saved_despawnable_bots
	new_save.depot_items = _saved_depot_items
	new_save.vault_items = _saved_vault_items
	new_save.quests = _saved_quests
	new_save.paths = _saved_paths
	ResourceSaver.save(SAVE_DIR + "save_" + str(current_save_slot) + ".tres",
		new_save)


func _on_LevelManager_tree_exiting() -> void:
	stop_player(true)
	save_to_disk()


var _in_game_menu_visible: bool = false


func _process(_delta: float) -> void:
	if is_instance_valid(_player) == false:
		return
	if Input.is_action_just_pressed("ui_cancel") && _in_game_menu_visible == false:
		if _player.ui_inventory.visible == true:
			_player.ui_inventory.visible = false
			_player.ui_inventory.held.visible = false
			_in_game_menu_visible = true
		$CanvasLayer/InGameMenu.visible = true
		$CanvasLayer/ColorRect3.visible = true
		get_tree().paused = true
		return
	if _in_game_menu_visible == true:
		_player.ui_inventory.visible = true
		_player.ui_inventory.held.visible = true
		_in_game_menu_visible = false


func _on_scene_changed(new_lvl: Node, spawn: String) -> void:
	$Resume.start()
	$Anim.play("transition")
	yield(self, "resume")
	if is_instance_valid(_current_scene) == true:
		if _current_scene.get_node("Bots").get_children().has(_player):
			_player.get_parent().remove_child(_player)
		_save_depot_items(_current_scene)
		_save_vault_items(_current_scene)
		_save_despawnable_bots()
	call_deferred("_on_scene_changed_deferred", new_lvl, spawn)


func _on_scene_changed_deferred(new_lvl: Node, spawn: String) -> void:
	if is_instance_valid(_current_scene) == true:
		_current_scene.free()
	var player = _instance_player(new_lvl.name)
	_current_scene = new_lvl
	$CanvasLayer/AreaName.text = _current_scene.disp_name
	_connect_level_components(_current_scene)
	_current_scene.get_node("Bots").add_child(player)
	add_child(_current_scene)
	player.position = _current_scene.get_node(spawn).global_position
	_load_quest(_current_scene)
	_load_saved_paths(_current_scene)
	_resume(player)


func _instance_player(new_lvl: String) -> Node:
	if new_lvl == "Tutorial":
		if is_instance_valid(_player_tut) == false:
			_player_tut = scenes["PlayerTut"].instance()
		return _player_tut
	else:
		if is_instance_valid(_player) == false:
			_player = scenes["Player"].instance()
			_load_player_items()
		if _player.is_connected("dead", self, "_on_player_dead") == false:
			_player.connect("dead", self, "_on_player_dead")
		_player.get_node("Name/Label").text = current_save_name
		return _player


func _connect_level_components(lvl: Node) -> void:
	if lvl.has_signal("quest_updated") == true:
		lvl.connect("quest_updated", self, "_on_quest_updated")
	_connect_access(lvl)
	_connect_bots(lvl)
	_connect_nav(lvl)


func _connect_access(lvl: Node) -> void:
	for access in lvl.get_node("Access").get_children():
		match access.get_script():
			Global.BOT_STATION:
				access.connect("spawn_saved", self, "_on_player_spawn_saved",
					[lvl.name, access.name])
			Global.NEXT_ZONE:
				access.connect("scene_changed", self, "_on_next_zone",
					[lvl.name, access.name])
			Global.DEPOT:
				_load_depot_items(lvl, access)
			Global.VAULT:
				_load_vault_items(access)


func _connect_bots(lvl: Node) -> void:
	for bot in lvl.get_node("Bots").get_children():
		if bot.respawnable == false:
			var bot_name = lvl.name + bot.name
			if _saved_despawnable_bots.keys().has(bot_name) == false:
				_saved_despawnable_bots[bot_name] = true
			elif (_saved_despawnable_bots.keys().has(bot_name) &&
				_saved_despawnable_bots[bot_name] == false):
				bot.free()
				continue
			bot.connect("dead", self, "_on_despawnable_bot_dead", [lvl.name + bot.name])


func _connect_nav(lvl: Node) -> void:
	for nav in lvl.get_node("Nav").get_children():
		if nav.has_signal("path_found") == true:
			nav.connect("path_found", self, "_on_hidden_path_found",
				[lvl.name, nav.name])


func _on_Anim_animation_finished(anim_name: String) -> void:
	match anim_name:
		"transition":
			if $Anim.is_playing() == true:
				$Anim.stop()
			$Anim.play("new_area")


func _on_next_zone(prev_lvl: String, nxt_lvl: String) -> void:
	$CanvasLayer/AreaName.visible = false
	var lvl = scenes[nxt_lvl].instance()
	var spawn = "Access/" + prev_lvl + "/Pos"
	_on_scene_changed(lvl, spawn)


func _resume(player) -> void:
	#resume interrupted charge cooldown
	var player_charge_time: float = player.get_node("Timers/ChargeCooldown").time_left
	if player_charge_time > 0:
		player.animate_bar_charge_level(player_charge_time)


########################################
# levels that need access to saved info
########################################
const HUB_KEY: = preload("res://levels proper/main/Key.gd")


var _quest_dict: Dictionary = {
	"Hub": {
		"Script": preload("res://levels proper/0_hub/Hub.gd"),
		"Quest": "KEYS"
	},
	"Area3-1": {
		"Script": preload("res://levels proper/3-1_area/Area3-1.gd"),
		"Quest": "DACS"
	},
	"TheEnd": {
		"Script": preload("res://levels proper/the end/TheEnd.gd"),
		"Quest": "SECRETS"
	}
}


func _set_info(lvl):
	if lvl is _quest_dict["Hub"]["Script"]:
		_pass_info_to_lvl(lvl, _quest_dict["Hub"])
	elif lvl is _quest_dict["Area3-1"]["Script"]:
		_pass_info_to_lvl(lvl, _quest_dict["Area3-1"])
	elif lvl is _quest_dict["TheEnd"]["Script"]:
		_pass_info_to_lvl(lvl, _quest_dict["TheEnd"])
		lvl.set_parent(self)
		stop_player(true)


func _pass_info_to_lvl(lvl: Node, dict: Dictionary) -> void:
	if _saved_quests.keys().has(dict["Quest"]) == false:
		_saved_quests[dict["Quest"]] = []
	lvl.set_quest(_saved_quests[dict["Quest"]])


########
# quests
########
func _on_quest_updated(quest_key: String, val_name: String) -> void:
	if _saved_quests.keys().has(quest_key) == false:
		_saved_quests[quest_key] = []
	if _saved_quests[quest_key].has(val_name) == true:
		return
	_saved_quests[quest_key].append(val_name)
	match quest_key:
		"KEYS":
			_play_objective_anim("KEY OBTAINED")
		"DACS":
			_play_objective_anim("CANNONS DISABLED: %s/5" % _saved_quests["DACS"].size())
		"SECRETS":
			_play_objective_anim("HIDDEN AREA DISCOVERED")


func _play_objective_anim(text: String) -> void:
	$CanvasLayer/StatusLabel.text = text
	if $Anim.current_animation != "destroyed":
		$Anim.queue("objective")


func _load_quest(lvl: Node) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is HUB_KEY:
			var key_name: String = lvl.name + access.name
			if _saved_quests["KEYS"].has(key_name) == true:
				access.queue_free()
	_set_info(lvl)


##################
# despawnable bots
##################
var _temp_despawnable_bots: Dictionary = {}


func _on_despawnable_bot_dead(bot: String) -> void:
	if (is_instance_valid(_player) == false ||
		_player.state == Global.CLASS_BOT.State.DEAD):
		return
	_temp_despawnable_bots[bot] = false
	if $Anim.is_playing() == false:
		$Anim.play("white_flash")


func _save_despawnable_bots() -> void:
	for key in _temp_despawnable_bots.keys():
		_saved_despawnable_bots[key] = _temp_despawnable_bots[key]
	_temp_despawnable_bots = {}


#############
# depot items
#############
func _save_depot_items(lvl: Node) -> void:
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


func _load_depot_items(lvl: Node, access: Node) -> void:
		var depot_name = lvl.name + access.name
		if _saved_depot_items.keys().has(depot_name) == false:
			return
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
	if is_instance_valid(trash_slot.item) == true:
		trash_slot.item.free()
	#save as array
	var keys = ["Items", "Weapons", "Passives"]
	#detach items
	var items: Array
	for key in keys:
		if key == "Weapons":
			for weap in _player.arr_weapons:
				if is_instance_valid(weap) == true:
					items.append(weap)
		else:
			items = _player.get_node(key).get_children()
		for item in items:
			_saved_player[key].append(item.filename)
			#cloning because the weapon becomes invisible as soon as the
			#weapon gets removed as a child
			if item == _player.current_weapon:
				_player.get_node("Weapons").add_child(item.duplicate())
			if is_instance_valid(item.get_parent()) == true:
				item.get_parent().remove_child(item)
		items = []


func _load_player_items() -> void:
	var keys = ["Items", "Weapons", "Passives"]
	for key in keys:
		if key == "Weapons" && _saved_player["Weapons"].size() != 0:
			var built_in_weap = _player.get_node(key).get_child(0)
			built_in_weap.get_parent().remove_child(built_in_weap)
		for item_path in _saved_player[key]:
			var item = load(item_path).instance()
			#add as node
			_player.get_node(key).add_child(item)
	#clear saved player items
	for arr in keys:
		_saved_player[arr].clear()


###############
# player spawn
###############
func _on_player_spawn_saved(lvl: String, pos: String) -> void:
	_saved_player["Spawn"] = {}
	_saved_player["Spawn"]["Lvl"] = lvl
	_saved_player["Spawn"]["Pos"] = "Access/" + pos


func _load_player_spawn() -> void:
	var level
	if _saved_player["Spawn"] == null:
		level = scenes["Tutorial"].instance()
		_on_scene_changed(level, "Access/Area1-1/Pos")
	else:
		level = scenes[_saved_player["Spawn"]["Lvl"]].instance()
		_on_scene_changed(level, _saved_player["Spawn"]["Pos"])


#############
# vault items
#############
func _save_vault_items(lvl: Node) -> void:
	for access in lvl.get_node("Access").get_children():
		if access is Global.VAULT:
			var vault_items = access.get_node("Items").get_children()
			for item in vault_items:
				_saved_vault_items.append(item.filename)
				item.get_parent().remove_child(item)


func _load_vault_items(access: Node) -> void:
	for i in _saved_vault_items.size():
		var item = load(_saved_vault_items[i]).instance()
		access.get_node("Items").add_child(item)
	_saved_vault_items.clear()


##############
# secret paths
##############
func _on_hidden_path_found(lvl: String, destructible: String) -> void:
	var path_name: String = lvl + destructible
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
	_temp_despawnable_bots = {}
	_save_player_items()
	_save_vault_items(_current_scene)
	_save_depot_items(_current_scene)
	$RespawnTimer.start()
	$CanvasLayer/StatusLabel.text = "DESTROYED"
	if $Anim.is_playing() == true:
		$Anim.stop()
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
