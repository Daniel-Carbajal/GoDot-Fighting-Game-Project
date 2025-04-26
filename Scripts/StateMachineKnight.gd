extends StateMachine #Essentially a shell/template from StateMachine
@export var id = 1

func _ready():
	add_state("STAND")
	add_state("JUMP_SQUAT")
	add_state("SHORT_HOP")
	add_state("FULL_HOP")
	add_state("DASH")
	add_state("MOONWALK")
	add_state("WALK")
	call_deferred("set_state", states.STAND)
	

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)

func get_transition(delta):
	parent.move_and_slide()
	
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
			pass
		states.SHORT_HOP:
			pass
		states.FULL_HOP:
			pass
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

func enter_state(new_state, old_state):
	pass

func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
