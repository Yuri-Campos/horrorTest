extends CharacterBody3D


@onready var camera_3d = $Camera3D
@onready var origin_cam_pos: Vector3 = camera_3d.position

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

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _process(delta):
	if(is_bob_on):
		cam_movement(delta)
	
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
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if !is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("action_jump") and is_on_floor():
		velocity.y = jump_vel
	

	move_and_slide()
	
