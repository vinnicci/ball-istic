extends "res://scenes/global/items/_base/_BaseItem.gd"


export (PackedScene) var Projectile
export (float) var heat_per_shot: float = 1 setget , get_heat_per_shot
export (float) var heat_cap: float = 5 setget , get_heat_cap
export (float) var heat_dissipation: float = 0 setget , get_heat_dissipation
#heat must be below this threshold to return firing
export (float, 0, 1.0) var almost_overheating_threshold: float = 0.75 setget , get_almost_overheating_threshold
export (float, 0, 1.0) var heat_below_threshold: float = 0 setget , get_heat_below_threshold
export (float) var shoot_cooldown: float = 1.0 setget set_shoot_cooldown, get_shoot_cooldown
export (float) var crit_mult: float = 2.0 setget , get_crit_mult
export (float) var crit_chance: float = 0.05 setget , get_crit_chance
#firemode related properties
enum FireModes {AUTO, BURST, CHARGE, MELEE, OTHER}
export (FireModes) var fire_mode
export (int) var proj_count_per_shot: int = 1 setget , get_proj_count_per_shot
export (float) var spread: float = 0 setget , get_spread #degrees
export (int) var recoil: int = 0 setget , get_recoil
export (float) var cam_shake_intensity: float = 0
#works only with burst firing mode
export (int) var burst_count: int = 1 setget , get_burst_count
export (float) var burst_timer: float = 0.02 setget , get_burst_timer
#works only with charge firing mode
export (float) var charge_timer: float = 3.0 setget , get_charge_timer
#works only with melee attacks
export (float) var melee_damage: float = 20 setget , get_melee_damage
export (float) var melee_crit_stun_time: float = 0 setget , get_melee_crit_stun_time
export (int) var melee_knockaback: int = 500 setget , get_melee_knockback

var current_heat_cap: float
var current_heat_per_shot: float
var current_heat: float
var current_heat_disspation: float
var current_shoot_cooldown: float
var current_crit_mult: float
var current_crit_chance: float
enum HeatStates {
	NOT_OVERHEATING,
	ALMOST_OVERHEATING,
	OVERHEATING
}
var heat_state = HeatStates.NOT_OVERHEATING
var weap_commit: bool = false

onready var _timer_shoot_cooldown: Node = $Timers/ShootCooldown
onready var _timer_burst_timer: Node = $Timers/BurstTimer
onready var _timer_charge_cancel_timer: Node = $Timers/ChargeCancelTimer
onready var _timer_dissipation_cooldown: Node = $Timers/DissipationCooldown


func get_heat_per_shot():
	return heat_per_shot

func get_heat_cap():
	return heat_cap

func get_heat_dissipation():
	return heat_dissipation

func get_almost_overheating_threshold():
	return almost_overheating_threshold

func get_heat_below_threshold():
	return heat_below_threshold

func set_shoot_cooldown(new_shoot_cooldown: float):
	shoot_cooldown = new_shoot_cooldown
	$Timers/ShootCooldown.wait_time = shoot_cooldown

func get_shoot_cooldown():
	return shoot_cooldown

func get_crit_mult():
	return crit_mult

func get_crit_chance():
	return crit_chance

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

func get_melee_damage():
	return melee_damage

func get_melee_crit_stun_time():
	return melee_crit_stun_time

func get_melee_knockback():
	return melee_knockaback


func _ready() -> void:
	reset_weap_vars()


func get_description() -> String:
	var s_description: String
	var sample_proj
	if is_instance_valid(Projectile) == true:
		sample_proj = Projectile.instance()
	var dmg_rate = _level_node.get_player().current_weap_dmg_rate
	match fire_mode:
		FireModes.MELEE:
			var f_dmg: int = dmg_rate * melee_damage
			s_description = ("MELEE DMG: " + str(f_dmg) +
				"	DPS: " + str(int(f_dmg / current_shoot_cooldown)))
		FireModes.AUTO, FireModes.BURST, FireModes.CHARGE:
			if (sample_proj is Global.CLASS_BOT_PROJ &&
				sample_proj.has_node("AI") == true):
				pass
			else:
				var f_dmg: int
				if sample_proj.has_node("Explosion") == true:
					f_dmg = dmg_rate * sample_proj.get_node("Explosion").damage
					s_description = ("EXPLOSION DMG: " + str(f_dmg) + _get_dps(f_dmg))
				else:
					f_dmg = dmg_rate * sample_proj.damage
					s_description = ("PROJECTILE DMG: " + str(f_dmg) + _get_dps(f_dmg))
	if s_description == "":
		return description
	else:
		return s_description + "\n" + description


func _get_dps(f_dmg) -> String:
	var f_dps: int = (f_dmg * proj_count_per_shot * burst_count)/current_shoot_cooldown
	match fire_mode:
		FireModes.AUTO, FireModes.BURST:
			return "	DPS: " + str(f_dps)
		FireModes.CHARGE:
			return ("	DPC: " +
				str(int(f_dmg * proj_count_per_shot * burst_count)))
	return ""


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
	_timer_burst_timer.wait_time = burst_timer
	current_heat_cap = heat_cap
	current_heat = 0
	current_heat = clamp(current_heat, 0, current_heat_cap + 1)
	#most AI bots have disspation advantage
	if current_heat_disspation == 0:
		current_heat_disspation = heat_dissipation
	current_crit_mult = crit_mult
	current_crit_chance = crit_chance
	current_crit_chance = clamp(current_crit_chance, 0, 1.0)


func _process(_delta: float) -> void:
	#almost overheat state
	#use this for weapons that make use of heat mechanics
	if (heat_state == HeatStates.NOT_OVERHEATING &&
		current_heat > current_heat_cap * almost_overheating_threshold):
		heat_state = HeatStates.ALMOST_OVERHEATING
	elif (heat_state == HeatStates.ALMOST_OVERHEATING &&
		current_heat <= current_heat_cap * almost_overheating_threshold):
		heat_state = HeatStates.NOT_OVERHEATING
	
	#overheat state
	if heat_state == HeatStates.ALMOST_OVERHEATING && current_heat > current_heat_cap:
		heat_state = HeatStates.OVERHEATING
	elif (heat_state == HeatStates.OVERHEATING &&
		current_heat <= current_heat_cap * heat_below_threshold):
		heat_state = HeatStates.ALMOST_OVERHEATING


func _on_DissipationCooldown_timeout() -> void:
	if current_heat_disspation <= 0:
		return
	if current_heat > 0:
		current_heat -= current_heat_disspation * 0.25 #<- rate 1sec/4
	elif current_heat <= 0:
		current_heat = 0


func _on_ShootCooldown_timeout() -> void:
	$Muzzle/MuzzleParticles.emitting = false


func animate_transform(transform_speed: float, visibility: bool) -> void:
	if visibility == false:
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0),
			transform_speed*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif visibility == true:
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1),
			transform_speed*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$WeaponTween.start()


######################
# all the firing modes
######################
func fire() -> void:
	if _timer_shoot_cooldown.is_stopped() == false || heat_state == HeatStates.OVERHEATING:
#		_parent_node.state != Global.CLASS_BOT.State.TURRET):
		return
	_timer_shoot_cooldown.start()
	$Muzzle/MuzzleParticles.emitting = true
	current_heat += current_heat_per_shot
	match fire_mode:
		FireModes.AUTO: _fire_auto()
		FireModes.BURST: _fire_burst()
		FireModes.CHARGE: _fire_charged()
		FireModes.MELEE: _fire_melee()
		FireModes.OTHER: _fire_other()


func _spawn_proj() -> void:
	_level_node.spawn_projectile(_modify_proj(Projectile), $Muzzle.global_position,
		$Muzzle.global_rotation + deg2rad(rand_range(-spread, spread)))


#do stuff here like adding critical effect, z index modification, etc.!
func _modify_proj(proj_pack) -> Node:
	var proj = proj_pack.instance()
	proj.set_shooter(_parent_node, _parent_node.current_faction)
	proj.set_level(_level_node)
	if proj is Global.CLASS_BOT_PROJ:
		_apply_bot_proj_stats(proj)
	_apply_crit(proj)
	return proj


func _apply_bot_proj_stats(proj) -> void:
	proj.health_cap *= _parent_node.current_weap_dmg_rate
	proj.weap_dmg_rate *= 0.5 * _parent_node.current_weap_dmg_rate
	proj.charge_dmg_rate += 0.05 * _parent_node.current_weap_dmg_rate


func _apply_crit(proj) -> void:
	if rand_range(0, 1.0) <= current_crit_chance:
		var mult = _parent_node.current_weap_dmg_rate * current_crit_mult
		if proj.has_node("Explosion") == true:
			proj.get_node("Explosion").damage *= mult
		else:
			proj.damage *= mult
		#crit feedback display
		proj.is_crit = true
	else:
		if proj.has_node("Explosion") == true:
			proj.get_node("Explosion").damage *= _parent_node.current_weap_dmg_rate
		else:
			proj.damage *= _parent_node.current_weap_dmg_rate


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
# melee attack
################################################################################
func _fire_melee() -> void:
	$ShootingSound.play()
	_apply_recoil()


func _on_HurtBox_body_entered(body: Node) -> void:
	var knockback_dir: float = (body.global_position - global_position).angle()
	if body is Global.CLASS_BOT:
		if body.current_faction == _parent_node.current_faction:
			return
		elif (body.current_faction != _parent_node.current_faction &&
			body.state == Global.CLASS_BOT.State.DEAD):
			return
		else:
			body.take_damage(_apply_melee_crit(body),
				Vector2(melee_knockaback, 0).rotated(knockback_dir))
			body.emit_spark(position)
			if body.has_node("AI") == true:
				body.get_node("AI").engage(_parent_node)
	else:
		body.take_damage(melee_damage, Vector2(melee_knockaback, 0).rotated(knockback_dir))


func _apply_melee_crit(body) -> float:
	var dmg: float
	if rand_range(0, 1.0) <= crit_chance:
		dmg = melee_damage * _parent_node.current_weap_dmg_rate * crit_mult
		_apply_melee_crit_effect(body)
		body.crit_effect()
	else:
		dmg = melee_damage * _parent_node.current_weap_dmg_rate
	return dmg


func _apply_melee_crit_effect(body) -> void:
	pass


func _on_Anim_animation_finished(anim_name: String) -> void:
	pass


################################################################################
# charge fire
# shoot by charging and then releasing, shootcooldown node is the time to charge,
# chargecanceltimer node is the delay of letting go to cancel charge
################################################################################
var _actual_heat: float = 0
onready var _timer_charge_cooldown = $Timers/ChargeCooldown


func _fire_charged() -> void:
	if (heat_state == HeatStates.OVERHEATING ||
		_timer_charge_cooldown.is_stopped() == false):
		_cancel_charge()
		return
	if current_heat == current_heat_cap:
		if current_heat_disspation <= 0:
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
			current_heat_cap, charge_timer, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$ChargingTween.start()
	_timer_charge_cancel_timer.start()


func _charge_fire() -> void:
#	if _parent_node.state != Global.CLASS_BOT.State.TURRET:
#		return
	pass


func _on_ChargeCancelTimer_timeout() -> void:
	_cancel_charge()
	if current_heat_disspation <= 0:
		current_heat = _actual_heat
	else:
		current_heat = 0


func _cancel_charge() -> void:
	$ChargingTween.stop_all()
	$ChargingSound.stop()
	_timer_dissipation_cooldown.paused = false


################################################################################
# other
# for special weapons
################################################################################
func _fire_other() -> void:
	pass
