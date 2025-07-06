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
	
	
func Hitbox_Collide(body):
	if !(body in player_list):
		var charstate
		charstate = body.get_node("StateMachine")
		weight = body.weight
		body.percentage += damage
		knockbackVal = knockback(body.percentage, damage, weight, kb_scaling, base_kb, 1)
		#s_angle(body) not needed if it doesnt work when implimented
		angle_flipper(body)
		body.knockback = knockbackVal
		body.hitstun = getHitstun(knockbackVal/0.3)
		get_parent().connected = true
		body.fr()
		charstate.state = charstate.states.HITSTUN
	
@export var percentage = 0
@export var weight = 150
@export var base_knockback = 40
@export var ratio = 1

func knockback(p,d,w,ks,bk,r):
	percentage = p
	damage = d
	weight = w
	kb_scaling = ks
	base_kb = bk
	ratio = r
	return ((((((((percentage/10) +(percentage*damage/20)) * (200/ (weight + 100)) *1.4)+18)*(kb_scaling))+base_kb)*1))*.004
	
func angle_flipper(body):
	var xangle
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
