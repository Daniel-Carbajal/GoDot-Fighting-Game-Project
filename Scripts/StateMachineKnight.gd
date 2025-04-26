extends StateMachine #Essentially a shell/template from StateMachine
@export var id = 1

func _ready():
	add_state("STAND")
	add_state("JUMP_SQUAT")
	add_state("SHORT_HOP")
	add_state("FULL_HOP")
	add_state("AIR")
	add_state("DASH")
	add_state("MOONWALK")
	add_state("WALK")
	add_state("LANDING")
	call_deferred("set_state", states.STAND)
	

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)

func get_transition(delta):
	parent.move_and_slide()
	if LANDING() == true:
		parent.fr()
		return states.LANDING
		
	if FALLING() == true:
		return states.AIR
		
	match state: #like case or pattern matching
		states.STAND:
			if Input.get_action_strength("right_%s" % id) == 1: #if "right_%s" was the input of the player
				parent.turn(false)
				parent.velocity.x = parent.RUNSPEED 
				parent.fr()
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.turn(true)
				parent.velocity.x = -parent.RUNSPEED
				parent.fr()
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND: #if character still moving but in the standing state, it will slow down until 0 
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x,0) 
				
		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat: #Once we reach the 3rd frame of JUMP_SQUAT state
				if not Input.is_action_pressed("jump_%s" % id): #Check if the player isnt still holding the jump button
					parent.velocity.x = lerp(parent.velocity.x,0,0.08)
					parent.fr()
					return states.SHORT_HOP #If they arent holding it do a short hop
				else:
					parent.velocity.x = lerp(parent.velocity.x,0,0.08)
					parent.fr()
					return states.FULL_HOP #otherwise if they are holding it, do a full jump
					
		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent.fr()
			return states.AIR
			
		states.FULL_HOP:
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.fr()
			return states.AIR
			
		states.DASH:
			if Input.is_action_pressed("left_%s" % id): #pressing left but facing right
				if parent.velocity.x > 0:
					parent.fr()
				parent.velocity.x = -parent.DASHSPEED
			elif Input.is_action_pressed("right_%s" % id): #pressing right but facing left
				if parent.velocity.x < 0:
					parent.fr()
				parent.velocity.x = parent.DASHSPEED
			else:
				if parent.frame >= parent.dash_duration-1:
					return states.STAND
					
		states.MOONWALK:
			pass
			
		states.WALK:
			pass
			
		states.AIR:
			AIRMOVEMENT()
			
		states.LANDING:
			pass

func enter_state(new_state, old_state):
	pass

func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func AIRMOVEMENT():
	pass
	
func LANDING():
	if state_includes([states.AIR]):
		if(parent.GroundL.is_colliding()) and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			parent.fr()
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return false
	elif parent.GroundR.is_colliding() and parent.velocity.y > 0:
		var collider2 = parent.GroundR.get_collider()
		parent.fr()
		if parent.velocity.y > 0:
			parent.velocity.y = 0
		parent.fastfall = false
		return true

func FALLING():
	if state_includes([states.STAND]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():	
			return true
