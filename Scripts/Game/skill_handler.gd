extends Node

@export var battle_ui: Control
@export var cooldown_message: String

@onready var player: CharacterBody3D = $"../Player"
@onready var boss: CharacterBody3D = $"../Boss1"
@onready var melee_zone: Area3D = $"../MeleeZone"
@onready var range_zone: Area3D = $"../RangeZone"

var can_melee: bool = false
var can_ranged: bool = false
var is_casting: bool = false
var casting_skill: SkillResource
var casting_slot: int = -1
var cast_remaining: float = 0.0
var cast_position: Vector3
var buff_remaining: float = 0.0
var damage_multiplier: float = 1.0
var dot_skill: SkillResource
var dot_remaining: float = 0.0
var dot_tick_remaining: float = 0.0

func _ready() -> void:
	player.died.connect(stop_skills)
	boss.died.connect(stop_skills)

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if is_casting:
		for action in ["move_left", "move_right", "move_forward", "move_back", "jump"]:
			if event.is_action_pressed(action):
				cancel_cast()
				return
	var actions := ["skill_shift", "skill_1", "skill_2", "skill_3"]
	for i in range(actions.size()):
		if event.is_action_pressed(actions[i]):
			use_skill(i)

func use_skill(index: int) -> void:
	if player.is_dead or boss.is_dead or not player.can_move or not GameState.boss1_intro_seen:
		return
	if index < 0 or index >= GameState.skills.size() or index >= battle_ui.cooldowns.size():
		return
	var skill: SkillResource = GameState.skills[index]
	if skill == null:
		return
	if is_casting:
		player.play_cast_anim()
		battle_ui.update_error("Already casting!")
		return
	if battle_ui.cooldowns[index] > 0.0:
		battle_ui.update_error(cooldown_message)
		return
	if not target_available(skill):
		return
	var duration := float(skill.cast_time)
	if duration > 0.0:
		if player_is_moving() or not player.is_on_floor():
			battle_ui.update_error("Stand still to cast!")
			return
		is_casting = true
		casting_skill = skill
		casting_slot = index
		cast_remaining = duration
		cast_position = player.global_position
		battle_ui.start_player_cast(skill.skill_name, duration)
		player.play_cast_anim()
	else:
		apply_skill(skill, index)

func target_available(skill: SkillResource) -> bool:
	if skill.skill_range == GameDictionary.AtkRange.SELF:
		return true
	if not boss.is_selected:
		battle_ui.update_error("Select the boss first!")
		return false
	var in_range := melee_zone.overlaps_body(player) if skill.skill_range == GameDictionary.AtkRange.MELEE else range_zone.overlaps_body(player)
	if not in_range:
		battle_ui.update_error("Target is out of range!")
		return false
	return true

func player_is_moving() -> bool:
	return not Input.get_vector("move_left", "move_right", "move_forward", "move_back").is_zero_approx() or Input.is_action_pressed("jump") or Vector2(player.velocity.x, player.velocity.z).length() > 0.1 or player.dash_remaining > 0.0

func _physics_process(delta: float) -> void:
	if player.is_dead or boss.is_dead:
		return
	if buff_remaining > 0.0:
		buff_remaining = maxf(0.0, buff_remaining - delta)
		if buff_remaining == 0.0:
			damage_multiplier = 1.0
	if dot_remaining > 0.0:
		var dot_delta := minf(delta, dot_remaining)
		dot_remaining = maxf(0.0, dot_remaining - dot_delta)
		dot_tick_remaining -= dot_delta
		while dot_tick_remaining <= 0.0001 and dot_skill != null:
			dot_tick_remaining += maxf(0.01, dot_skill.tick_interval)
			boss.take_damage(dot_skill.skill_damage * damage_multiplier)
			if boss.is_dead:
				return
	if not is_casting:
		return
	if not player.can_move or player_is_moving() or not player.is_on_floor() or player.global_position.distance_to(cast_position) > 0.02:
		cancel_cast()
		return
	if not target_available(casting_skill):
		cancel_cast(false)
		return
	cast_remaining = maxf(0.0, cast_remaining - delta)
	battle_ui.cast_bar.value = float(casting_skill.cast_time) - cast_remaining
	if cast_remaining == 0.0:
		var skill := casting_skill
		var index := casting_slot
		is_casting = false
		casting_skill = null
		casting_slot = -1
		battle_ui.stop_player_cast()
		player.stop_cast_anim()
		apply_skill(skill, index)

func apply_skill(skill: SkillResource, index: int) -> void:
	battle_ui.start_skill_cooldown(index)
	match skill.skill_effect:
		SkillResource.SkillEffect.DAMAGE:
			boss.take_damage(skill.skill_damage * damage_multiplier)
		SkillResource.SkillEffect.DAMAGE_OVER_TIME:
			dot_skill = skill
			dot_remaining = skill.effect_duration
			dot_tick_remaining = maxf(0.01, skill.tick_interval)
		SkillResource.SkillEffect.RESET_COOLDOWNS:
			battle_ui.reset_other_cooldowns(index)
		SkillResource.SkillEffect.DASH:
			player.dash(skill.dash_distance)
		SkillResource.SkillEffect.DAMAGE_BUFF:
			damage_multiplier = skill.damage_multiplier
			buff_remaining = skill.effect_duration

func cancel_cast(show_message: bool = true) -> void:
	if not is_casting:
		return
	is_casting = false
	casting_skill = null
	casting_slot = -1
	cast_remaining = 0.0
	battle_ui.stop_player_cast()
	player.stop_cast_anim()
	if show_message:
		battle_ui.update_error("Cast interrupted!")

func stop_skills() -> void:
	cancel_cast(false)
	buff_remaining = 0.0
	damage_multiplier = 1.0
	dot_remaining = 0.0
	dot_skill = null
	player.dash_remaining = 0.0

func _on_melee_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_melee = true

func _on_melee_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_melee = false

func _on_range_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_ranged = true

func _on_range_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_ranged = false
