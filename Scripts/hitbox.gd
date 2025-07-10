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
@export var ang_flip = 0
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
	ang_flip = af
	update_extents()
	body_entered.connect(Callable(self, "Hitbox_Collide"))
	set_physics_process(true)
	
	
func Hitbox_Collide(body):
	if !(body in player_list): 
		player_list.append(body)
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
		
func getHitstun(kb):
	return floor(kb * 0.533)
	
@export var percentage = 0
@export var weight = 100
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
	
	
const angleConversion = PI / 180

func getHorizantalDecay(ang): #rate at which the opponent will slow down after knockback
	var decay = 0.051 + cos(ang * angleConversion) #Rate of decay is 0.051, to get horizantal rate; multiply by horizontal(cos) angle in radians
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay) #absolute value, because for decay, a negative value means we are speeding up

func getVerticalDecay(ang): #rate at which character slows down
	var decay = 0.051 + sin(ang * angleConversion) #converts angle to radians
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay) #A negative decay would mean that the player is speeding up
	
func getHorizantalVelocity(knockback, ang): #gets horizontal knockback speed wit total knockback and angle
	var initV = knockback * 30
	var horizontalAngle = cos(ang * angleConversion) #converts angle to radians
	var horizontalVelocity = initV * horizontalAngle
	horizontalVelocity = round(horizontalVelocity * 100000) / 100000
	return horizontalVelocity 
	
func getVerticalVelocity(knockback, ang):
	var initV = knockback * 30
	var vertAngle = sin(ang * angleConversion) #converts angle to radians
	var vertVelocity = initV * vertAngle
	vertVelocity = round(vertVelocity * 100000) / 100000
	return vertVelocity

func angle_flipper(body):
	var xangle
	if get_parent().direction() == -1: #if facing left
		xangle = (-(((body.global_position.angle_to_point(get_parent().global_position))*180)/PI))
	else: #otherwise if facing right
		xangle = (((body.global_position.angle_to_point(get_parent().global_position))*180)/PI)
		
	match ang_flip:
		0:
			var flipped_angle = angle
			if get_parent().direction() == -1: #Flips angle, if attacker is facing left
				flipped_angle = 180 - angle

			body.velocity.x = getHorizantalVelocity(knockbackVal, flipped_angle) #seems to be working correctly
			print("Initial velocity of attack is: " + str(body.velocity.x))
			body.velocity.y = getVerticalVelocity(knockbackVal, flipped_angle)
			body.hdecay = getHorizantalDecay(flipped_angle)
			body.vdecay = getVerticalDecay(flipped_angle)
		1:
			if get_parent().GrabF.global_rotation_degrees == -180:
				xangle = -(((self.global_position.angle_to_point(body.get_parent().global_position))*180)/PI)
			else:
				xangle = (((self.global_position.angle_to_point(body.get_parent().global_position))*180)/PI)
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, xangle+180)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -xangle)))
			body.hdecay = (getHorizantalDecay(xangle+180))
			body.vdecay = (getVerticalDecay(xangle))
		2:
			if get_parent().GrabF.global_rotation_degrees == -180:
				xangle = -(((body.get_parent().global_position.angle_to_point(self.global_position))*180)/PI)
			else:
				xangle = (((body.get_parent().global_position.angle_to_point(self.global_position))*180)/PI)
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, -xangle+100)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -xangle)))
			body.hdecay = (getHorizantalDecay(xangle+180))
			body.vdecay = (getVerticalDecay(xangle))
		3:
			if get_parent().GrabF.global_rotation_degrees == -180:
				xangle = (-(((body.global_position.angle_to_point(self.global_position))*180)/PI))+180
			else:
				xangle = (((body.global_position.angle_to_point(self.global_position))*180)/PI)
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, xangle)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -angle)))
			body.hdecay = (getHorizantalDecay(xangle))
			body.vdecay = (getVerticalDecay(angle))
		4:
			if get_parent().GrabF.global_rotation_degrees == -180:
				xangle = -(((body.global_position.angle_to_point(self.global_position))*180)/PI)+180
			else:
				xangle = (((body.global_position.angle_to_point(self.global_position))*180)/PI)
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, -xangle*180)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -angle)))
			body.hdecay = (getHorizantalDecay(angle))
			body.vdecay = (getVerticalDecay(angle))
		5:
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, angle+180)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -angle)))
			body.hdecay = (getHorizantalDecay(angle+180))
			body.vdecay = (getVerticalDecay(angle))
		6:
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, xangle)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -angle)))
			body.hdecay = (getHorizantalDecay(xangle))
			body.vdecay = (getVerticalDecay(angle))
		7:
			body.velocity.x = ((getHorizantalVelocity(knockbackVal, -xangle+180)))
			body.velocity.y = ((getVerticalVelocity(knockbackVal, -angle)))
			body.hdecay = (getHorizantalDecay(angle))
			body.vdecay = (getVerticalDecay(angle))
			

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
