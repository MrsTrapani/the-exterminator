extends CharacterBody3D

@onready var rotation_indicator: Sprite3D = $RotationIndicator
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D


var is_selected: bool = false
var can_be_selected: bool = false
var player: Node3D

func _ready() -> void:
	rotation_indicator.hide()


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if not is_instance_valid(player):
		return

	var direction := player.global_position - global_position
	direction.y = 0.0
	if not direction.is_zero_approx():
		#arrow rotata
		rotation_indicator.global_rotation.y = atan2(direction.x, direction.z)


func _on_selection_zone_mouse_entered() -> void:
	can_be_selected = true


func _on_selection_zone_mouse_exited() -> void:
	can_be_selected = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb") and can_be_selected:
		if is_selected:
			rotation_indicator.hide()
			is_selected = false
			print("boss selected")
			return
		else:
			rotation_indicator.show()
			is_selected = true
			print("boss unselected")
			return
