extends Area2D

var parent = get_parent()
@export var width = 300
@export var height = 400
@export var damage = 50
@export var angle = 90
@export var base_kb = 100
@export var kb_scaling = 2
@export var duration = 1500
@export var hitlag_modifier = 1
@export var type = 'normal'
@export var angle_flipper = 0
@onready var hitbox = get_node("Hitbox_Shape")
@onready var parentState = get_parent().selfState
var knockbackVal
var framez = 0.0
var player_list = []

func set_parameters(w,h,d,a,b_kb,kb_s,dur,t,p,af,hit,parent=get_parent()):
	self.position = Vector2(0,0)
	player_list.append(parent) #append the player that is spawning this hitbox, so they cant be hit by their own attack
	player_list.append(self)   #append self just incase, so the hitbox doesnt collide with itself
	width = w
	height = h
	damage = d
	angle = a
	base_kb = b_kb
	kb_scaling = kb_s
	duration = dur
	type = t
	self.position = p
	hitlag_modifier = hit
	angle_flipper = af
	update_extents()
	area_entered.connect(Callable(self, "Hitbox_Collide"))
	set_physics_process(true)
	
	
func Hitbox_Collide():
	pass
	
func update_extents():
	hitbox.shape.extents = Vector2(width, height)
	
func _ready():
	hitbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	pass
	
func _physics_process(delta):
	if framez<duration:
		framez+=1
	elif framez==duration:
		Engine.time_scale = 1
		queue_free() #wait for current code to execute before deletion 
		return
	if get_parent().selfState != parentState: #if the characters attack ends suddenly, get rid of the hitbox (character gets attack mid of their own attack)
		Engine.time_scale = 1
		queue_free()
		return
