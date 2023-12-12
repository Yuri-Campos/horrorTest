extends CharacterBody3D


@onready var camera_3d = $Camera3D
@onready var origin_cam_pos: Vector3 = camera_3d.position
@onready var floor_detect_raycast:RayCast3D = $FloorDetectorRaycast
@onready var step_sound: AudioStreamPlayer3D = $StepSound

@export var mouse_sens: float= 0.15
@export var cam_bob_speed: float = 6
@export var cam_bob_up_down: float = 0.5
@export var is_bob_on: bool = false

const GRAVITY: float = 9.8

var direction: Vector3
var speed: int = 2
var jump_vel: int = 4
var _delta:float = 0.0

var cam_bob
var obj_cam

var distance_footstep: float = 0.0
var play_footstep: int = 3
var is_running: bool = false
var stamina: float = 100.0
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if Input.is_action_just_pressed("action_run"):
		is_running = true
	if Input.is_action_just_released("action_run"):
		is_running = false
func _process(delta):
	if(is_bob_on):
		cam_movement(delta)	
		
	if floor_detect_raycast.is_colliding():
		var walkingterrain = floor_detect_raycast.get_collider().get_parent()
		if walkingterrain != null:
			var terraingroup = walkingterrain.get_groups()[0]
			process_ground_sounds(terraingroup)
		
		
func _physics_process(delta) -> void:
	process_movement(delta)
	
func cam_movement(delta):
	_delta += delta
	
	if direction != Vector3.ZERO:
		cam_bob = floor(abs(direction.z) + abs(direction.x)) * _delta * cam_bob_speed
		obj_cam = origin_cam_pos + Vector3.UP * sin(cam_bob) * cam_bob_up_down	
	else:
		cam_bob = floor(abs(1) + abs(1)) * _delta * 0.6
		obj_cam = origin_cam_pos + Vector3.UP * sin(cam_bob) * 0.1
		
	
	camera_3d.position = camera_3d.position.lerp(obj_cam, delta)
	
func process_movement(delta) -> void:
	direction = Vector3.ZERO
	
	var h_rot := global_transform.basis.get_euler().y
	
	direction.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	direction.z = -Input.get_action_strength("ui_up") + Input.get_action_strength("ui_down")
	
	direction = Vector3(direction.x, 0, direction.z).rotated(Vector3.UP, h_rot).normalized()
	
	
	var char_speed = speed * 1.5 if is_running && stamina > 0 else speed
	velocity.x = direction.x * char_speed
	velocity.z = direction.z * char_speed
	
	if !is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("action_jump") and is_on_floor():
		velocity.y = jump_vel
	
	move_and_slide()
	
func process_ground_sounds(group: String):
	
	if is_running:
		play_footstep = 2
	else:
		play_footstep = 3
		
		
	if (int(velocity.x) != 0) || int (velocity.z) != 0:
		distance_footstep += 0.1
		
	if distance_footstep > play_footstep and is_on_floor():
		match group:
			"terrain_wood":
				step_sound.stream = load("res://sounds/steps/wood/1.ogg")
			"terrain_grass":
				step_sound.stream = load("res://sounds/steps/grass/1.ogg")	
		
		step_sound.pitch_scale = randf_range(0.8, 1.2)
		step_sound.play()
		
		distance_footstep = 0.0
	
