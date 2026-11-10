extends CanvasLayer

var fade_time: float = 0.6
var black: ColorRect

func _ready() -> void:
	layer = 100
	black = ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func reset_battle() -> void:
	var tween := create_tween()
	tween.tween_property(black, "color:a", 1.0, fade_time)
	await tween.finished
	var tree := get_tree()
	var result := tree.reload_current_scene()
	if result != OK:
		push_error("Could not reset battle: " + error_string(result))
		queue_free()
		return
	await tree.scene_changed
	var battle_ui: Control = tree.current_scene.get_node("BattleUI")
	tween = create_tween()
	tween.tween_property(black, "color:a", 0.0, fade_time)
	await tween.finished
	if not battle_ui.player.is_dead and not battle_ui.tutorial.visible:
		battle_ui.player.can_move = true
	queue_free()
