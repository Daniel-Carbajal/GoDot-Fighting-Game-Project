extends CharacterBody2D

#Global Variables
var frame = 0
@export var id: int
var dir = 1 #which direction is char facing (spawn into world facing right)

#Attributes
@export var percentage = 0
@export var stocks = 0
@export var weight = 150

#Knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

#Landing Variables
var landing_frames = 5
var lag_frames = 5
var perfect_wavedash_modifier = .75

#Air Variables
var dash_duration = 10
var jump_squat = 5 #Before the character jumps it enters JUMP_SQUAT which is 3 frames
var fastfall = false
var airJump = 0
@export var airJumpMax = 1

#Ledge Variables
var last_ledge = false
var regrab = 30
var catch = false

#Hitboxes
@export var hitbox: PackedScene
var selfState

#OnReady Variables
@onready var GroundR = get_node('Raycasts/GroundR')
@onready var GroundL = get_node('Raycasts/GroundL')
@onready var GrabF = get_node('Raycasts/Ledge_Grab_F')
@onready var GrabB = get_node('Raycasts/Ledge_Grab_B')
@onready var states = $State
@onready var sprite = get_node("Sprite/AnimationPlayer")
@onready var percentLabel = get_parent().get_node("P%s" % id)

#Knights main attributes
var RUNSPEED = 400
var CROUCHSPEED = 150
var DASHSPEED = 450
var WALKSPEED = 200
var GRAVITY = 1800
var JUMPFORCE = 600
var MAX_JUMPFORCE = 1000
var DOUBLEJUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 900
var MAXFALLSPEED = 900
var TRACTION = 40
var ROLL_DISTANCE = 350
var air_dodge_speed = 500
var UP_B_LAUNCHSPEED = 700

func direction():
	return dir

#creates a hitbox with attributes given and applies those attributes in its own script through set parameters
func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag=1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	#rotate the points
	if direction() == 1: #if we are facing right
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
	else: #otherwise if the character is facing left
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
	return hitbox_instance

func updateframes(delta):
	frame += 1

func turn(direction):
	if direction: #facing right and turning left
		dir = -1
		GrabF.position.x = -8
		GrabF.global_rotation_degrees = 180 
		GrabB.global_rotation_degrees = 180
	elif direction == false: #facing left and turning right
		dir = 1
		GrabF.position.x = 8
		GrabF.global_rotation_degrees = 0
		GrabB.global_rotation_degrees = 0
	$Sprite.set_flip_h(direction)
	

func fr():
	frame = 0

func reset_ledge():
	last_ledge = false

func reset_Jumps():
	airJump = airJumpMax


# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

func _physics_process(delta):
	$Frames.text = str(frame)
	$facing.text = str(GrabF.rotation_degrees)
	$facingB.text = str(GrabB.rotation_degrees)
	selfState = states.text
	percentLabel.text = str(percentage)

#Tilt attacks with attack attributes
#Order of create_hitbox parameters in terms of attack attributes:
#	width of hitbox, height of hitbox, damage, angle of knockback, base knockback, knockback scaling, duration, 
#	type of attack, hitbox spawnpoint, angle_flipper val, hitlag val   
func down_swing_1():
	if frame == 4:
		create_hitbox(35,10,25,90,2000,5,3,'normal',Vector2(7,18.5),0,1)
	if frame >= 12:
		return true

func forward_swing():
	if frame == 10:
		create_hitbox(35,12,15,15,3000,3.5,3,'normal',Vector2(10,8),0,1)
	if frame >= 21:
		return true
		
func up_swing():
	if frame == 8:
		#create_hitbox(32,10,8,60,3,1,3,'normal',Vector2(20,-32),0,1)
		create_hitbox(18.5,25.5,20,45,3000,5,3,'normal',Vector2(33.5,4),0,1)
	if frame >= 20:
		return true

#Air Attacks
func NAIR():
	if frame == 1:
		create_hitbox()
	if frame > 1:
		if connected == true:
			if frame == 36:
				connected = false
				return true
		else:
			if frame == 5:
				#create_hitbox()
				if frame == 36:
					return true
				
func UAIR():
	if frame == 2:
		create_hitbox()
	if frame == 6:
		create_hitbox()
	if frame == 15:
		return true
		
func BAIR():
	if frame == 2:
		create_hitbox()
	if frame > 1:
		if connected == true:
			if frame == 10:
				connected = false
				return true
		else:
			if frame == 7:
				create_hitbox()
			if frame == 10:
				return true
				
func FAIR():
	if frame == 2:
		create_hitbox()
	if frame == 11:
		create_hitbox()
	if frame == 18:
		return true
		
func DAIR():
	var framesList = [2,3,5,7,9,11]
	if frame in framesList:
		create_hitbox()
	if frame == 14:
		create_hitbox()
	if frame == 17:
		return true
		
