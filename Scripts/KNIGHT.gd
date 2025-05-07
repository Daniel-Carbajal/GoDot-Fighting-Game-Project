extends CharacterBody2D

#Global Variables
var frame = 0
#4var direction = Vector2()

#Landing Variables
var landing_frames = 5
var lag_frames = 5

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

#OnReady Variables
@onready var GroundR = get_node('Raycasts/GroundR')
@onready var GroundL = get_node('Raycasts/GroundL')
@onready var GrabF = get_node('Raycasts/Ledge_Grab_F')
@onready var GrabB = get_node('Raycasts/Ledge_Grab_B')
@onready var states = $State
@onready var sprite = get_node("Sprite/AnimationPlayer")

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

func updateframes(delta):
	frame += 1

func turn(direction):
	var dir = 0
	if direction:
		dir = -1
		GrabF.position.x = -8
		GrabF.global_rotation_degrees = 180 
		GrabB.global_rotation_degrees = 180
	elif direction == false:
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

