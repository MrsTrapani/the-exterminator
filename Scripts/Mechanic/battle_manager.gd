extends Node

@export var battle_resource: BattleResource

@onready var minutes_bygone: Node = $"../MinutesBygone"
@onready var hour_strike: Node = $"../HourStrike"
@onready var ringtone: Node = $"../Ringtone2"
@onready var quarter_chime: Node = $"../QuarterChime"
@onready var player: CharacterBody3D = $"../Player"
@onready var battle_ui: Control = $"../BattleUI"
@onready var aggro_range: Area3D = $"../AggroRange"
@onready var death_zone: Area3D = $"../Death"
@onready var boss: CharacterBody3D = $"../Boss1"

@export var minutes_bygone_dialogue: String
@export var hourstrike_dialogue: String
@export var ringtone_dialogue: String
@export var reverse_ringtone_dialogue: String
@export var quarterchime_dialogue: String
@export var overclock_dialogue: String
@export var ringinghour_dialogue: String
@export var reverse_ringinghour_dialogue: String
@export var overclockedquarter_dialogue: String
@export var reverse_ravenous_dialogue: String
@export var ravenous_dialogue: String
@export var finalchime_dialogue: String

var timeline: Array[Dictionary] = []
var elapsed_time: float = 0.0
var next_mechanic: int = 0
var battle_started: bool = false
var is_busy: bool = false
var has_started: bool = false

func _ready() -> void:
	player.died.connect(stop_battle)
	boss.died.connect(stop_battle)
	death_zone.body_entered.connect(player_fell)
	read_battle()

func read_battle() -> void:
	timeline.clear()
	if battle_resource == null:
		return
	for line in battle_resource.line:
		var parts := line.split(",")
		if parts.size() != 2 or not parts[0].strip_edges().is_valid_float():
			push_warning("Invalid battle line: " + line)
			continue
		timeline.append({"time": float(parts[0]), "mechanic": parts[1].strip_edges()})
	timeline.sort_custom(sort_by_time)

func sort_by_time(first: Dictionary, second: Dictionary) -> bool:
	return first.time < second.time

func start_battle() -> void:
	if GameState.is_loading or not GameState.boss1_intro_seen or has_started or player.is_dead or boss.is_dead or not player.can_move:
		return
	read_battle()
	if timeline.is_empty():
		push_warning("Battle resource has no mechanics.")
		return
	has_started = true
	battle_started = true
	battle_ui.battle_started = true
	elapsed_time = 0.0
	next_mechanic = 0

func _process(delta: float) -> void:
	if not has_started and player.can_move and aggro_range.overlaps_body(player):
		start_battle()
	if not battle_started:
		return
	elapsed_time += delta
	if is_busy or next_mechanic >= timeline.size():
		return
	var entry := timeline[next_mechanic]
	if elapsed_time >= entry.time:
		next_mechanic += 1
		is_busy = true
		await play_mechanic(entry.mechanic)
		is_busy = false

func play_mechanic(mechanic_name: String) -> void:
	match mechanic_name:
		"MinutesBygone":
			battle_ui.show_boss_speech(minutes_bygone_dialogue)
			await minutes_bygone.start_mechanic()
		"Overclock":
			battle_ui.show_boss_speech(overclock_dialogue)
			await minutes_bygone.start_mechanic(true)
		"HourStrike":
			battle_ui.show_boss_speech(hourstrike_dialogue)
			await hour_strike.start_mechanic()
		"Ringtone":
			battle_ui.show_boss_speech(ringtone_dialogue)
			await ringtone.start_mechanic(1)
		"ReverseRingtone", "ReversedRingtone":
			battle_ui.show_boss_speech(reverse_ringtone_dialogue)
			await ringtone.start_mechanic(2)
		"QuarterChime":
			battle_ui.show_boss_speech(quarterchime_dialogue)
			await quarter_chime.start_mechanic()
		"RingingHourStrike":
			battle_ui.show_boss_speech(ringinghour_dialogue)
			await hour_strike.start_mechanic(true, 1)
		"ReverseRingingHourStrike", "ReversedRingingHourStrike":
			battle_ui.show_boss_speech(reverse_ringinghour_dialogue)
			await hour_strike.start_mechanic(true, 2)
		"OverclockedQuarterChime":
			battle_ui.show_boss_speech(overclockedquarter_dialogue)
			await quarter_chime.start_mechanic(true)
		"RavenousMidnightChime":
			battle_ui.show_boss_speech(ravenous_dialogue)
			await quarter_chime.start_mechanic(true, true, -1, 1)
		"ReverseRavenousMidnightChime", "ReversedRavenousMidnightChime":
			battle_ui.show_boss_speech(reverse_ravenous_dialogue)
			await quarter_chime.start_mechanic(true, true, -1, 2)
		"FinalChime":
			battle_ui.show_boss_speech(finalchime_dialogue)
			SignalHub.boss_cast_started.emit("Final Chime", 10.0)
			await get_tree().create_timer(10.0, false).timeout
			if battle_started and not player.is_dead and not boss.is_dead:
				player.take_damage(player.max_health)
		_:
			push_warning("Unknown mechanic: " + mechanic_name)

func stop_battle() -> void:
	battle_started = false
	minutes_bygone.stop_mechanic()
	hour_strike.stop_mechanic()
	quarter_chime.stop_mechanic()
	ringtone.stop_mechanic()
	battle_ui.stop_boss_cast()

func player_fell(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.take_damage(body.max_health)
