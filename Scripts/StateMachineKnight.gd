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
	
	if LANDING() == true: #if the character is landing
		parent.fr() #reset the frames
		return states.LANDING #return the landing state
		
	if FALLING() == true: #if the character is falling
		return states.AIR #return the air state
		
	match state: #like case or pattern matching
		states.STAND:
			if Input.get_action_strength("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
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
			if parent.frame <= parent.landing_frames + parent.lag_frames: #Checking if we are still landing
				if parent.frame == 1: #If we are still landing and its on the first frame of landing, nothing happens
					pass
				if parent.velocity > 0: #If knights is moving to the right
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2 #Than the knight will slow down
					parent.velocity.x = clamp(parent.velocity.x, 0 ,parent.velocity.x) #The knight is only able to slow down to a speed of zero(otherwise it would be moving to the left)
				elif parent.velocity.x < 0: #If knights moving to the left
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2 #than the knight will slow down 
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0) #The knight can only slow down to zero (otherwise velocity.x > 0 is moving to right)
				if Input.is_action_just_pressed("jump_%s" % id): 
					parent.fr()
					return states.JUMP_SQUAT
			else: 
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.fr()
					return states.CROUCH
				else:
					parent.frame()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0

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
	if parent.velocity.y < parent.FALLSPEED: #If vert velocity is less than the FALLSPEED, increase vert velocity 
		parent.velocity.y += parent.FALLSPEED #In GoDot, positive y is inverted, so + to y, is down
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall: 
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true: #if we are fast falling
		parent.set_collision_mask_bit(2,false) #character will be able to fall through platforms
		parent.velocity.y = parent.MAXFALLSPEED
		
	#If the characters X velocity is greater/equal to the MAXAIRSPEED in either directions(using abs)
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0: 							#moving right handler^ (only reached if greater than MAXAIRSPEED)
			if Input.is_action_pressed("left_%s" % id): 	#press left
				parent.velocity.x += -parent.AIR_ACCEL 		#begin drifting left
			elif Input.is_action_pressed("right_%s" % id):  #press right
				parent.velocity.x = parent.velocity.x		#continue moving right
		if parent.velocity.x < 0: 							#moving left handler^(inverse to right) (only reached if greater than MAXAIRSPEED)
			if Input.is_action_pressed("left_%s" % id):		#press left
				parent.velocity.x = parent.velocity.x		#continue moving left
			elif Input.is_action_pressed("right_%s" % id):	#press right
				parent.velocity.x += parent.AIR_ACCEL		#begin drifitng right
				
	#If the characters velocity is less than the MAXAIRSPEED in either directions
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED): 
		if Input.is_action_pressed("left_%s" % id): 	#press left
			parent.velocity.x += -parent.AIR_ACCEL		#speed up moving to left
		elif Input.is_action_pressed("right_%s" % id): 	#press right
			parent.velocity.x += parent.AIR_ACCEL		#speed up moving to right
			
	#If you are not pressing left or right
	if not Input.is_action_pressed("right_%s" % id) and not Input.is_action_pressed("left_%s" % id):
		if parent.velocity.x < 0: #if characters was moving left
			parent.velocity.x += parent.AIR_ACCEL/5 #add AIR_ACCEL to slow them down to zer0
		elif parent.velocity.x > 0: #if characters was moving right
			parent.velocity.x += -parent.AIR_ACCEL/5 #subtract AIR_ACCEL to slow them down to zer0
	
func LANDING():
	if state_includes([states.AIR]): #if the character is withing any of the provided states (within state_includes)
		if(parent.GroundL.is_colliding()) and parent.velocity.y > 0: #if the characters left foot is touching the ground and its vert velocity is greater than 0
			var collider = parent.GroundL.get_collider() #store what the foot is colliding with
			parent.fr() #reset frame count
			if parent.velocity.y > 0: 
				parent.velocity.y = 0 #reset vert velocity
			parent.fastfall = false #end the fastfall because we are now on the ground
			return true
			
		elif (parent.GroundR.is_colliding()) and parent.velocity.y > 0: #if the characters right foot is touching the ground and its vert velocity is greater than zer0
			var collider2 = parent.GroundR.get_collider() #store what the foot is colliding with
			parent.fr() #reset frame count
			if parent.velocity.y > 0: 
				parent.velocity.y = 0 #reset vert velocity
			parent.fastfall = false #end the fastfall because we are now on the ground
			return true

func FALLING():
	if state_includes([states.STAND, states.DASH]): #if the character is withing any of the provided states (within state_includes)
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():	
			return true #if neither of the characters feet are touching the ground, it is falling(return true)
