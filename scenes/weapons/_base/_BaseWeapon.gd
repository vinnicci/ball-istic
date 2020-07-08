extends "res://scenes/global/items/_base/_BaseItem.gd"


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1 setget , get_heat_per_shot
export (float) var heat_capacity: float = 5 setget , get_heat_capacity
export (float) var heat_dissipation_per_sec: float = 1 setget , get_heat_dissipation
#heat must be below this threshold to return firing
export (float, 0, 1.0) var almost_overheating_threshold: float = 0.75 setget , get_almost_overheating_threshold
export (float, 0, 1.0) var heat_below_threshold: float = 0 setget , get_heat_below_threshold
export (float) var shoot_cooldown: float = 1.0 setget set_shoot_cooldown, get_shoot_cooldown
export (float) var proj_damage_rate: float = 1.0
#firemode related properties
enum FireModes {AUTO, BURST, CHARGE, OTHER}
export (FireModes) var fire_mode
export (int) var proj_count_per_shot: int = 1 setget , get_proj_count_per_shot
export (int) var burst_count: int = 1 setget , get_burst_count
export (float) var spread: float = 0 setget , get_spread #degrees
export (int) var recoil: int = 0 setget , get_recoil
#works only with burst firing mode
export (float) var burst_timer: float = 0.02 setget , get_burst_timer
#works only with charge firing mode
export (float) var charge_timer: float = 3.0 setget , get_charge_timer
export (float) var cam_shake_intensity: float = 0

var current_heat_per_shot: float = 0
var current_heat: float = 0
var current_heat_dissipation: float
var current_shoot_cooldown: float
var _is_almost_overheating: bool = false setget , is_almost_overheating
var _is_overheating: bool = false setget , is_overheating
var weap_commit: bool = false
var level_node: Node = null

onready var _timer_shoot_cooldown: Node = $Timers/ShootCooldown
onready var _timer_burst_timer: Node = $Timers/BurstTimer
onready var _timer_charge_cancel_timer: Node = $Timers/ChargeCancelTimer
onready var _timer_dissipation_cooldown: Node = $Timers/DissipationCooldown


func get_heat_per_shot():
	return heat_per_shot

func get_heat_capacity():
	return heat_capacity

func get_heat_dissipation():
	return heat_dissipation_per_sec

func get_almost_overheating_threshold():
	return almost_overheating_threshold

func get_heat_below_threshold():
	return heat_below_threshold

func set_shoot_cooldown(new_shoot_cooldown: float):
	shoot_cooldown = new_shoot_cooldown
	$Timers/ShootCooldown.wait_time = shoot_cooldown

func get_shoot_cooldown():
	return shoot_cooldown

func get_fire_mode():
	return fire_mode

func get_proj_count_per_shot():
	return proj_count_per_shot

func get_burst_count():
	return burst_count

func get_spread():
	return spread

func get_recoil():
	return recoil

func get_burst_timer():
	return burst_timer

func get_charge_timer():
	return charge_timer

func is_almost_overheating():
	return _is_almost_overheating

func is_overheating():
	return _is_overheating


func _ready() -> void:
	reset_weap_vars()


func reset_weap_vars() -> void:
	if fire_mode == FireModes.CHARGE:
		#charge fire mode uses another var actual_heat
		#makes sure there's no heat per shot
		#and letting go for atleast 0.05 sec means cancelling charge
		_actual_heat = 0
		current_shoot_cooldown = 0.05
		_timer_shoot_cooldown.wait_time = current_shoot_cooldown
	else:
		current_heat_per_shot = heat_per_shot
		current_shoot_cooldown = shoot_cooldown
		_timer_shoot_cooldown.wait_time = current_shoot_cooldown
	current_heat_dissipation = heat_dissipation_per_sec
	_timer_burst_timer.wait_time = burst_timer
	current_heat = 0
	current_heat = clamp(current_heat, 0, heat_capacity + 1)


func _process(_delta: float) -> void:
	#almost overheat state
	#use this for weapons that make use of heat mechanics
	if _is_almost_overheating == false && current_heat > heat_capacity * almost_overheating_threshold:
		_is_almost_overheating = true
	elif _is_almost_overheating == true && current_heat <= heat_capacity * almost_overheating_threshold:
		_is_almost_overheating = false
	
	#overheat state
	if _is_overheating == false && current_heat > heat_capacity:
		_is_overheating = true
	elif _is_overheating == true && current_heat <= heat_capacity * heat_below_threshold:
		_is_overheating = false


func _on_DissipationCooldown_timeout() -> void:
	if current_heat_dissipation <= 0:
		return
	if current_heat > 0:
		current_heat -= current_heat_dissipation * 0.25 #<- rate 1sec/4
	elif current_heat <= 0:
		current_heat = 0


func _on_ShootCooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false


func animate_transform(transform_speed: float) -> void:
	if modulate == Color(1,1,1,1):
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0),
			transform_speed*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif modulate == Color(1,1,1,0):
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1),
			transform_speed*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$WeaponTween.start()


######################
# all the firing modes
######################
func fire() -> void:
	if (_timer_shoot_cooldown.is_stopped() == false || _is_overheating == true ||
		_parent_node.state != Global.CLASS_BOT.State.TURRET):
		return
	_timer_shoot_cooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	current_heat += current_heat_per_shot
	match fire_mode:
		FireModes.AUTO: _fire_auto()
		FireModes.BURST: _fire_burst()
		FireModes.CHARGE: _fire_charged()
		FireModes.OTHER: _fire_other()


func _spawn_proj() -> void:
	level_node.spawn_projectile(_instance_proj(), $Muzzle.global_position,
		$Muzzle.global_rotation + deg2rad(rand_range(-spread, spread)),
		_parent_node.current_faction, _parent_node)


func _instance_proj() -> Node:
	var proj = Projectile.instance()
	_modify_proj(proj)
	if proj is Global.CLASS_PROJ:
		proj.set_level(level_node)
		proj.set_shooter(_parent_node)
		proj.damage *= proj_damage_rate
		if proj.has_node("Explosion") == true:
			var explosion_node = proj.get_node("Explosion")
			if is_instance_valid(level_node.get_player()) == true:
				explosion_node.set_player_cam(level_node.get_player().get_node("Camera2D"))
			explosion_node.set_level_cam(level_node.get_node("Camera2D"))
	return proj


#do stuff here like adding critical effect, z index modification, etc.!
func _modify_proj(proj) -> void:
	pass


func _apply_recoil() -> void:
	if _parent_node.has_node("Camera2D") == true:
		_parent_node.get_node("Camera2D").shake_camera(cam_shake_intensity, 0.05, 0.05)
	_parent_node.apply_knockback(Vector2(recoil, 0).rotated(global_rotation - deg2rad(180)))


################################################################################
# auto fire
# fire one or more projectiles at once, shootcooldown node is the rate of fire
################################################################################
func _fire_auto() -> void:
	$ShootingSound.play()
	for i in proj_count_per_shot:
		_spawn_proj()
	_apply_recoil()


################################################################################
# burst fire
# fire rounds in bursts, shootcooldown node is the rate of fire, bursttimer node
# is the spawn delay for each projectile
################################################################################
var _current_burst_count: int = 0


func _fire_burst() -> void:
	$ShootingSound.play()
	_current_burst_count += 1
	_fire_auto()
	_apply_recoil()
	_timer_burst_timer.start()


func _on_BurstTimer_timeout() -> void:
	if _current_burst_count == burst_count || _parent_node.state != Global.CLASS_BOT.State.TURRET:
		_current_burst_count = 0
		return
	_fire_burst()


################################################################################
# charge fire
# shoot by charging and then releasing, shootcooldown node is the time to charge,
# chargecanceltimer node is the delay of letting go to cancel charge
################################################################################
var _actual_heat: float = 0
onready var _timer_charge_cooldown = $Timers/ChargeCooldown


func _fire_charged() -> void:
	if (_is_overheating == true || _parent_node.state != Global.CLASS_BOT.State.TURRET ||
		_timer_charge_cooldown.is_stopped() == false):
		_cancel_charge()
		return
	if current_heat == heat_capacity:
		if heat_dissipation_per_sec <= 0:
			_actual_heat += heat_per_shot
			current_heat = _actual_heat
			_timer_charge_cooldown.start(shoot_cooldown)
		else:
			current_heat += 1
		_timer_charge_cancel_timer.stop()
		_charge_fire()
		_cancel_charge()
		return
	if current_heat == _actual_heat:
		current_heat = 0
		$ChargingSound.play()
		_timer_dissipation_cooldown.paused = true
		$ChargingTween.interpolate_property(self, "current_heat", current_heat,
			heat_capacity, charge_timer, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$ChargingTween.start()
	_timer_charge_cancel_timer.start()


func _charge_fire() -> void:
	if _parent_node.state != Global.CLASS_BOT.State.TURRET:
		return


func _on_ChargeCancelTimer_timeout() -> void:
	_cancel_charge()
	if heat_dissipation_per_sec <= 0:
		current_heat = _actual_heat
	else:
		current_heat = 0


func _cancel_charge() -> void:
	$ChargingTween.stop_all()
	_timer_dissipation_cooldown.paused = false


################################################################################
# other
# for special weapons
################################################################################
func _fire_other() -> void:
	pass
