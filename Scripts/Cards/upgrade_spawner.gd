extends Node

@export var card_scene: PackedScene
@export var spawn_delay: float = 0.2

@onready var spawn_markers: Array[Marker3D] = [$"../Player/CameraPivot/Camera3D/UpgradeSpawn1", $"../Player/CameraPivot/Camera3D/UpgradeSpawn2", $"../Player/CameraPivot/Camera3D/UpgradeSpawn3"]

var spawned_cards: Array[Node3D] = []

func _ready() -> void:
	SignalHub.upgrade_selected.connect(despawn_unselected)

func spawn_cards() -> void:
	for marker in spawn_markers:
		var card := card_scene.instantiate() as Node3D
		add_child(card)
		card.global_transform = marker.global_transform
		spawned_cards.append(card)
		
		card.flip_card()
		await get_tree().create_timer(spawn_delay).timeout

func despawn_unselected(selection: Node3D) -> void:
	for card in spawned_cards:
		if is_instance_valid(card) and card != selection:
			card.despawn_card()
	
	spawned_cards.clear()
