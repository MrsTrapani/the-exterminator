extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 40.0
@export var deceleration: float = 50.0
@export var jump_velocity: float = 6.0
@export var gravity_multiplier: float = 1.8
@export var camera_sensitivity: float = 0.2

@export var max_health: float = 10000.0
var current_health: float = 10000.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var rotation_indicator: Sprite3D = $RotationIndicator

var facing: String = "F"
var rotating_camera: bool = false
var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
var can_move: bool = true


func _ready() -> void:
	sprite.play("Idle_F")


func _process(_delta: float) -> void:
	var camera_forward := -camera.global_basis.z
	# The floor indicator's arrow points along local +Z.
	rotation_indicator.global_rotation.y = atan2(camera_forward.x, camera_forward.z)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if not can_move:
		input_dir = Vector2.ZERO
		velocity.x = 0.0
		velocity.z = 0.0
	var camera_direction := Basis(Vector3.UP, camera_pivot.rotation.y)
	var direction := camera_direction * Vector3(input_dir.x, 0.0, input_dir.y)

	var move_rate: float = acceleration
	if input_dir.is_zero_approx():
		move_rate = deceleration

	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	var target_velocity := Vector2(direction.x, direction.z) * move_speed
	horizontal_velocity = horizontal_velocity.move_toward(target_velocity, move_rate * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.y

	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	elif can_move and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()
	update_animation(input_dir)


func update_animation(input_dir: Vector2) -> void:
	if absf(input_dir.x) > absf(input_dir.y):
		if input_dir.x > 0.0:
			facing = "R"
		else:
			facing = "L"
	elif not input_dir.is_zero_approx():
		if input_dir.y > 0.0:
			facing = "F"
		else:
			facing = "B"

	var animation: String = "Idle_" + facing
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		animation = "Walk_" + facing

	sprite.play(animation)


func _unhandled_input(event: InputEvent) -> void:
	if not can_move:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
		previous_mouse_mode = Input.mouse_mode
		rotating_camera = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
		stop_camera_rotation()
	elif event is InputEventMouseMotion and rotating_camera and can_move:
		camera_pivot.rotation.y -= deg_to_rad(event.relative.x * camera_sensitivity)
		camera_pivot.rotation.x -= deg_to_rad(event.relative.y * camera_sensitivity)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-30.0), deg_to_rad(-5.0))
		get_viewport().set_input_as_handled()


func stop_camera_rotation() -> void:
	if rotating_camera:
		rotating_camera = false
		Input.mouse_mode = previous_mouse_mode


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		stop_camera_rotation()


func _exit_tree() -> void:
	stop_camera_rotation()
