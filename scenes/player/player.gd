extends CharacterBody3D

class_name Player
enum team_types {good, evil}

@onready var username : String
@onready var alive : bool = true
@onready var team : team_types
@onready var role #add role enum
@onready var tasks #add task class
@onready var inventory #add item class


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera = $Camera3D
@onready var can_move = true

#look at mouse variables
var rayOrigin = Vector3()
var rayEnd = Vector3()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(self.name.to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	#initialize as local player
	camera.make_current()


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	#move player
	if can_move: 
		move(delta)

func move(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	###############################
	#MOUSE-LOOK AT BEHAVIOR#
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	rayOrigin = camera.project_ray_origin(mouse_pos) # set the ray origin
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_pos) * 2000 # set ray end-point
	
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd) # create ray query
	
	var intersection = space_state.intersect_ray(query) # get the ray hit
	
	if not intersection.is_empty(): # check if a valid ray hit exists and rotate toward it
		var pos = intersection.position
		$PlayerBody.look_at(Vector3(pos.x, position.y, pos.z), Vector3(0,1,0))


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	
	#Flashlight Toggle
	if Input.is_action_just_pressed("flashlight"):
		rpc("toggle_flashlight")

#this is dumb/delet this
func enable_input(result : bool):
	can_move = result

@rpc("call_local")
func toggle_flashlight():
	var flashlight = $PlayerBody/Flashlight
	if flashlight.visible:
		flashlight.hide()
	elif !flashlight.visible:
		flashlight.show()

#change username
@rpc("call_local")
func change_username(new_username):
	$Username.text = new_username
	username = new_username

@rpc("call_local", "authority", "reliable")
func change_team(new_team:team_types):
	team = new_team
