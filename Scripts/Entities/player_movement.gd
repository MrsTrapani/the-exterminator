extends CharacterBody3D

signal health_changed
signal died

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
var is_dead: bool = false
var is_casting: bool = false
var dash_remaining: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var dash_speed: float = 20.0


func _ready() -> void:
	current_health = max_health
	sprite.play("Idle_F")


func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	health_changed.emit()
	if current_health <= 0.0:
		is_dead = true
		can_move = false
		velocity = Vector3.ZERO
		dash_remaining = 0.0
		stop_camera_rotation()
		died.emit()


func _process(_delta: float) -> void:
	var camera_forward := -camera.global_basis.z


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

	var was_dashing := dash_remaining > 0.0
	if was_dashing:
		var dash_step := minf(delta, dash_remaining)
		velocity.x = dash_direction.x * dash_speed * dash_step / delta
		velocity.z = dash_direction.z * dash_speed * dash_step / delta
		dash_remaining = maxf(0.0, dash_remaining - delta)
	move_and_slide()
	if was_dashing and dash_remaining == 0.0:
		velocity.x = 0.0
		velocity.z = 0.0
	update_animation(input_dir)

func dash(distance: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_dir.is_zero_approx():
		dash_direction = -camera.global_basis.z
	else:
		dash_direction = Basis(Vector3.UP, camera_pivot.rotation.y) * Vector3(input_dir.x, 0.0, input_dir.y)
	dash_direction.y = 0.0
	dash_direction = dash_direction.normalized()
	dash_remaining = distance / dash_speed


func update_animation(input_dir: Vector2) -> void:
	if is_casting:
		return
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

func play_cast_anim() -> void:
	is_casting = true
	sprite.play("Cast_F")

func stop_cast_anim() -> void:
	is_casting = false
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if not can_move:
		input_dir = Vector2.ZERO
	update_animation(input_dir)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed and can_move:
			previous_mouse_mode = Input.mouse_mode
			rotating_camera = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			stop_camera_rotation()
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and rotating_camera and can_move:
		camera_pivot.rotation.y -= deg_to_rad(event.screen_relative.x * camera_sensitivity)
		camera_pivot.rotation.x -= deg_to_rad(event.screen_relative.y * camera_sensitivity)
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
