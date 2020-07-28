extends Node2D


#Nav node: attach tilemaps/static bodies with nav mesh and collision
#Bots node: attach bots
var _player: Global.CLASS_PLAYER = null setget , get_player
var _doors: Array
var _engaging_player_count: int = 0
var valid_bots: Array
var _proj_pool: Dictionary = {}


func get_player():
	return _player


func _ready() -> void:
	for bot in $Bots.get_children():
		if bot is Global.CLASS_PLAYER:
			_player = bot
		bot.set_level(self)
		add_bot(bot)
		_init_proj(bot, 30)
	for door in $Doors.get_children():
		_doors.append(door)
	open_doors()


func add_bot(bot) -> void:
	valid_bots.append(bot)
	bot.connect("dead", self, "_on_bot_dead", [bot])


#initialize pool -> also includes drone weapons
func _init_proj(bot, pool_size: int) -> void:
	var weap_arr = bot.get_node("Weapons").get_children()
	if weap_arr.size() == 0:
		return
	for weap in weap_arr:
		var proj_pack = weap.Projectile
		if proj_pack == null || _proj_pool.keys().has(proj_pack):
			return
		_proj_pool[proj_pack] = []
		for i in range(pool_size):
			var proj_inst = proj_pack.instance()
			if proj_inst is Global.CLASS_PROJ:
				_proj_pool[proj_pack].append(proj_inst)
			elif proj_inst is Global.CLASS_BOT:
				_proj_pool.erase(proj_pack)
				_init_proj(proj_inst, 30)
				return


var _doors_closed: bool = false


func set_engaging_player_count(value: bool) -> void:
	if value == true:
		_engaging_player_count += 1
	else:
		_engaging_player_count -= 1
	if _doors_closed == true && _engaging_player_count == 0:
		open_doors()
		_doors_closed = false
	elif _doors_closed == false && _engaging_player_count != 0:
		close_doors()
		_doors_closed = true


func open_doors() -> void:
	for door in _doors:
		door.open()


func close_doors() -> void:
	for door in _doors:
		door.close()


var _active_proj: Dictionary = {}


func spawn_projectile(proj, proj_position: Vector2, proj_direction: float,
	shooter_faction: Color, origin_weap) -> void:
#	add_child(proj)
#	if proj is Global.CLASS_BOT == true:
#		add_bot(proj)
#	proj.init_travel(proj_position, proj_direction, shooter_faction)
	var proj_inst
	if _proj_pool.keys().has(proj) == true:
		if _proj_pool[proj].size() != 0:
			proj_inst = _proj_pool[proj].pop_front()
		else:
			proj_inst = proj.instance()
		proj_inst.reset_proj_vars()
		origin_weap._modify_proj(proj_inst)
		_active_proj[proj_inst] = proj
	if proj_inst is Global.CLASS_BOT == true:
		add_bot(proj_inst)
	add_child(proj_inst)
	proj_inst.init_travel(proj_position, proj_direction, shooter_faction)


func despawn_projectile(proj) -> void:
	var proj_pack = _active_proj[proj]
	_proj_pool[proj_pack].append(proj)
	_active_proj.erase(proj)


func get_points(start: Vector2, end: Vector2) -> Array:
	var points: Array = $Nav.get_simple_path(start, end)
	return points


func _on_bot_dead(bot) -> void:
	if bot == _player:
		$Camera2D.global_position = _player.global_position
		$Camera2D.current = true
	valid_bots.erase(bot)


#anim effect cleanup -> critical, deflected, stunned, charge and teleport trail
func _on_Anim_finished(anim_name: String, anim_obj: Node) -> void:
	anim_obj.queue_free()
