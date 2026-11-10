extends Control

@onready var status_label: Label = $Overlay/Panel/Status
@onready var progress_bar: ProgressBar = $Overlay/Panel/Progress
@onready var warmup_viewport: SubViewport = $WarmupViewport
@onready var warmup_camera: Camera3D = $WarmupViewport/Camera3D
@onready var effects: Node3D = $WarmupViewport/Effects
@onready var back_button: Button = $Overlay/Panel/BackButton

var arena_path: String = "res://_Scene/Map/clockwork_reverie.tscn"
var effect_paths: Array[String] = ["res://_Scene/VFXVFX/pizza_explosion.tscn", "res://_Scene/VFXVFX/impact_simple_circle.tscn", "res://_Scene/VFXVFX/impact_simple_torus.tscn"]

func _ready() -> void:
	GameState.is_loading = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_button.hide()
	back_button.pressed.connect(return_to_test)
	warmup_camera.look_at(Vector3.ZERO, Vector3.UP)
	await draw_frame()
	var result := ResourceLoader.load_threaded_request(arena_path)
	if result != OK:
		loading_failed("Could not load arena: " + error_string(result))
		return
	var progress := []
	while true:
		var status := ResourceLoader.load_threaded_get_status(arena_path, progress)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			loading_failed("Could not load Clockwork Reverie.")
			return
		if not progress.is_empty():
			progress_bar.value = progress[0] * 100.0
		await get_tree().process_frame
	var packed_arena: PackedScene = ResourceLoader.load_threaded_get(arena_path)
	progress_bar.value = 100.0
	for i in range(effect_paths.size()):
		status_label.text = "Preparing effects... " + str(i + 1) + " / " + str(effect_paths.size())
		var packed_effect: PackedScene = load(effect_paths[i])
		if packed_effect == null:
			loading_failed("Could not prepare effect: " + effect_paths[i].get_file())
			return
		var effect: Node3D = packed_effect.instantiate()
		effects.add_child(effect)
		effect.play_effect()
		await draw_frame()
		var animation: AnimationPlayer = effect.get_node("AnimationPlayer")
		while animation.is_playing():
			await draw_frame()
		effect.queue_free()
		await get_tree().process_frame
	status_label.text = "Entering Clockwork Reverie..."
	warmup_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var arena := packed_arena.instantiate()
	get_tree().root.add_child(arena)
	await draw_frame()
	await draw_frame()
	get_tree().current_scene = arena
	queue_free()
	GameState.is_loading = false
	GameState.battle_loading_finished.emit()

func draw_frame() -> void:
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw

func loading_failed(message: String) -> void:
	GameState.is_loading = false
	status_label.text = message
	back_button.show()
	push_error(message)

func return_to_test() -> void:
	GameState.is_loading = false
	get_tree().change_scene_to_file("res://_Scene/Test/test.tscn")
