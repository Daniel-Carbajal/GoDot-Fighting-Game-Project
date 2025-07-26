extends StateMachine #Essentially a shell/template from StateMachine
@onready var id = get_parent().id

func _ready():
	add_state("STAND")
	add_state("JUMP_SQUAT")
	add_state("SHORT_HOP")
	add_state("FULL_HOP")
	add_state("AIR")
	add_state("DASH")
	add_state("WALK")
	add_state("LANDING")
	add_state("CROUCH")
	add_state("TURN")
	add_state("RUN")
	
	add_state("LEDGE_CATCH")
	add_state("LEDGE_HOLD")
	add_state("LEDGE_CLIMB")
	add_state("LEDGE_JUMP")
	add_state("LEDGE_ROLL")
	
	add_state("GROUND_ATTACK")
	add_state("DOWN_TILT")
	add_state("FORWARD_TILT")
	add_state("UP_TILT")
	add_state("JAB")
	
	add_state("AIR_ATTACK")
	add_state("NAIR")
	add_state("UAIR")
	add_state("BAIR")
	add_state("FAIR")
	add_state("DAIR")
	
	add_state("SPECIAL_ATTACK") #Not implemented as tree yet
	add_state("NEUTRAL_SPECIAL") 
	
	add_state("HIT_FREEZE")
	add_state("HITSTUN")
	call_deferred("set_state", states.STAND)

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab -= 1
	parent.hit_p(delta)

func get_transition(delta):
	parent.move_and_slide()
	#print("AIREAL is: " + str(AIREAL()))
	
	if LANDING() == true: #if the character is landing
		#print("Landing triggered")
		parent.fr() #reset the frames
		return states.LANDING #return the landing state
		
	if FALLING() == true: #if the character is falling
		#print("Falling triggered")
		return states.AIR #return the air state
		
	if Ledge() == true:
		parent.fr()
		return states.LEDGE_CATCH
	else:
		parent.reset_ledge()
		
	if Input.is_action_just_pressed("attack_%s" %id) && TILT() == true:
		parent.fr()
		return states.GROUND_ATTACK
		
	if Input.is_action_just_pressed("special_%s" % id) && SPECIAL() == true:
		parent.fr()
		return states.NEUTRAL_SPECIAL
		
	#ATTACK INPUT
	if Input.is_action_just_pressed("attack_%s" % id) && AIREAL() == true:
		if Input.is_action_pressed("up_%s" % id):
			parent.fr()
			return states.UAIR
		if Input.is_action_pressed("down_%s" % id):
			parent.fr()
			return states.DAIR
		match parent.direction():
			1:
				if Input.is_action_pressed("left_%s" % id):
					parent.fr()
					return states.BAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.fr()
					return states.FAIR
			-1:
				if Input.is_action_pressed("left_%s" % id):
					parent.fr()
					return states.FAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.fr()
					return states.BAIR
		parent.fr()
		return states.NAIR
		
	#L_cancel	
	#print("Trying to L-cancel | cooldown:", parent.cooldown, " | AIREAL:", AIREAL(), " | shield just pressed:", Input.is_action_just_pressed("shield_%s" % id))
	if Input.is_action_just_pressed("shield_%s" % id) && AIREAL() && parent.cooldown == 0:
		parent.l_cancel = 11
		parent.cooldown = 40 #can only l_cancel every 40 frames (or wtv this =)
		print("L_cancel is true")
		
	match state: #like case or pattern matching
		states.STAND:
			parent.reset_Jumps()
			if Input.get_action_strength("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent.fr()
				return states.CROUCH
			if Input.get_action_strength("right_%s" % id) == 1: #if "right_%s" was the input of the player
				parent.turn(false)
				parent.velocity.x = parent.RUNSPEED 
				parent.fr()
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1: #get_action_strength returns a val that is >=0 but <= 1 (useful for controller input
				parent.turn(true)
				parent.velocity.x = -parent.RUNSPEED
				parent.fr()
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND: #if character still moving but in the standing state, it will slow down until 0 
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x,0) 
				
		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat: #Once we reach the 3rd frame of JUMP_SQUAT state
				if(Input.is_action_pressed("shield_%s" % id)) and (Input.is_action_pressed("left_%s" % id) or Input.is_action_pressed("right_%s" % id)):
					if (Input.is_action_pressed("right_%s" % id)):
						parent.velocity.x = parent.air_dodge_speed/parent.perfect_wavedash_modifier
					if(Input.is_action_pressed("left_%s" % id)):
						parent.velocity.x = -parent.air_dodge_speed/parent.perfect_wavedash_modifier
					parent.lag_frames = 6
					parent.fr()
					return states.LANDING
				if not Input.is_action_pressed("jump_%s" % id): #Check if the player isnt still holding the jump button
					parent.velocity.x = lerpf(parent.velocity.x,0.0,0.08)
					parent.fr()
					return states.SHORT_HOP #If they arent holding it do a short hop
				else:
					parent.velocity.x = lerpf(parent.velocity.x,0.0,0.08)
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
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
			
			elif Input.is_action_pressed("down_%s" % id):
				parent.fr()
				return states.CROUCH
				
			elif Input.is_action_pressed("left_%s" % id): #pressing left but facing right
				if parent.velocity.x > 0:
					parent.fr()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent.fr()
					return states.RUN
					
			elif Input.is_action_pressed("right_%s" % id): #pressing left but facing right
				if parent.velocity.x < 0:
					parent.fr()
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent.fr()
					return states.RUN
					
			else:
				if parent.frame >= parent.dash_duration-1:
					return states.STAND
					
		states.WALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fr()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				parent.velocity.x = -parent.WALKSPEED* Input.is_action_just_pressed("left_%s" % id)
			elif Input.get_action_strength("right_%s" % id):
				parent.velocity.x = parent.WALKSPEED* Input.is_action_just_pressed("right_%s" % id)
			else:
				parent.fr()
				return states.STAND
			
		states.CROUCH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent.fr()
				return states.STAND
			if Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.CROUCHSPEED
			elif Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = -parent.CROUCHSPEED
			if parent.velocity.x > 0 and state == states.CROUCH: #if character still moving but in the standing state, it will slow down until 0 
				parent.velocity.x += -parent.TRACTION/3
				parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.CROUCH:
				parent.velocity.x += parent.TRACTION/3
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x,0) 
			
			
		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
				parent.turn(true)
				parent.velocity.x += -parent.TRACTION*2
				parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(false)
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			else:
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					parent.fr()
					return states.STAND
				else:
					parent.fr()
					return states.RUN
			
		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.fr()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fr()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
				else:
					parent.fr()
					return states.TURN
			elif Input.get_action_strength("right_%s" % id):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
				else:
					parent.fr()
					return states.TURN
			else:
				parent.fr()
				return states.STAND
			
		states.AIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
			if Input.is_action_just_pressed("special_%s" % id):
				parent.fr()
				return states.NEUTRAL_SPECIAL
			
		states.LANDING:
			if parent.frame == 1:
				#print("Landing Frame 1, l_cancel =", parent.l_cancel)
				if parent.l_cancel > 0: #if you l_cancel within a certain # of frames from landing
					parent.lag_frames = floor(parent.lag_frames / 2) #cut lag frames in half
			if parent.frame <= parent.landing_frames + parent.lag_frames: #Checking if we are still landing
				if parent.velocity.x > 0: #If knights is moving to the right
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2 #Than the knight will slow down
					parent.velocity.x = clampf(parent.velocity.x, 0 ,parent.velocity.x) #The knight is only able to slow down to a speed of zero(otherwise it would be moving to the left)
				elif parent.velocity.x < 0: #If knights moving to the left
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2 #than the knight will slow down 
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0) #The knight can only slow down to zero (otherwise velocity.x > 0 is moving to right)
				if Input.is_action_just_pressed("jump_%s" % id): 
					parent.fr()
					return states.JUMP_SQUAT
			else: 
				if Input.is_action_pressed("down_%s" % id):
					parent.l_cancel = 0
					parent.lag_frames = 0
					parent.fr()
					parent.reset_Jumps()
					return states.CROUCH
				else:
					parent.l_cancel = 0
					parent.fr()
					parent.lag_frames = 0
					parent.reset_Jumps()
					return states.STAND
				parent.lag_frames = 0
				return states.STAND
				
		states.LEDGE_CATCH:
			if parent.frame > 7:
				parent.lag_frames = 0
				parent.reset_Jumps()
				parent.fr()
				return states.LEDGE_HOLD
			
		states.LEDGE_HOLD:
			if parent.frame >= 390: 
				self.parent.position.y += -25
				parent.fr()
				return states.AIR 
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fastfall = true
				parent.regrab = 30
				parent.reset_ledge()
				self.parent.position.y += -25
				parent.catch = false
				parent.fr()
				return states.AIR
			#Facing Right
			elif parent.GrabF.rotation_degrees == 0: 
				if Input.is_action_just_pressed("left_%s" % id): #Facing ledge on right and press left, player should fall
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab = 30
					parent.reset_ledge()
					#self.parent.position.y += -25 Not really needed, it was also causing a collision error with the platform
					parent.catch = false
					parent.fr()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s" % id): #facing ledge on right and press right, then climb ledge
					parent.fr()
					return states.LEDGE_CLIMB 
				elif Input.is_action_just_pressed("shield_%s" % id): # NOT IMPLEMENTED
					parent.fr()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id): 
					parent.fr()
					return states.LEDGE_JUMP
				
			#Facing Left
			elif parent.GrabF.rotation_degrees == -180:
				if Input.is_action_just_pressed("right_%s" % id): #Facing ledge on left and press right, player should fall
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab = 30
					parent.reset_ledge()
					#self.parent.position.y += -25 Not really needed, it was also causing a collision error with the platform
					parent.catch = false
					parent.fr()
					return states.AIR
				elif Input.is_action_just_pressed("left_%s" % id): # Facing ledge on left and press left, then climb ledge
					parent.fr()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("sheild_%s" % id): # NOT IMPLEMENTED
					parent.fr()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.fr()
					return states.LEDGE_JUMP
				
		states.LEDGE_CLIMB: # frame by frame teleporting character to work with climb anim
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 25
			if parent.frame == 10:
				parent.position.y -= 25
			if parent.frame == 20:
				parent.position.y -= 25
			if parent.frame == 22:
				parent.catch = false
				parent.position.y -= 25
				#parent.position.x += 50*parent.direction()
				if parent.GrabF.global_rotation_degrees == -180:
					parent.position.x -= 30
				elif parent.GrabF.global_rotation_degrees == 0:
					parent.position.x += 30
			if parent.frame == 25:
				parent.velocity.y = 0
				parent.velocity.x = 0
				#parent.move_and_collide(Vector2(parent.direction*20,50))
			if parent.frame == 30:
				parent.reset_ledge()
				parent.fr()
				return states.STAND
			
		states.LEDGE_JUMP:
			if parent.frame > 14:
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.fr()
					return states.AIR_ATTACK
				if Input.is_action_just_pressed("special_%s" % id):
					parent.fr()
					return states.SPECIAL
			if parent.frame == 5:
				parent.reset_ledge()
				parent.position.y -= 20
			if parent.frame == 10:
				parent.catch = false
				parent.position.y -= 20
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.fr()
					return states.AIR
			if parent.frame == 15:
				parent.position.y -= 20
				parent.velocity.y -= parent.DOUBLEJUMPFORCE
				if parent.GrabF.global_rotation_degrees == -180:
					parent.velocity.x -= 220
				elif parent.GrabF.global_rotation_degrees == 0:
					parent.velocity.x += 220
				#parent.velocity.x += 220 #Meant to be an arc that the character jumps into based on the direction the character is facing
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.fr()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.fr()
					return states.AIR_ATTACK
			elif parent.frame > 15 and parent.frame < 20:
				parent.velocity.y += parent.FALLSPEED
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.fr()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.fr()
					return states.AIR_ATTACK
			if parent.frame == 20:
				parent.fr()
				return states.AIR
			
		states.LEDGE_ROLL:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 30
			if parent.frame == 10:
				parent.position.y -= 30
			if parent.frame == 20:
				parent.catch = false
				parent.position.x += 30*parent.direction()
			if parent.frame > 22 and parent.frame < 28:
				parent.position.x += 30*parent.direction()
				
			if parent.frame == 29:
				parent.move_and_collide()
			if parent.frame == 30:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.reset_ledge()
				parent.fr()
				return states.STAND
				
		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed("up_%s" % id):
				parent.fr()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent.fr()
				return states.DAIR
				
			match parent.direction():
				1: #if facing right in the air
					if Input.is_action_pressed("left_%s" % id):
						parent.fr()
						return states.BAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.fr()
						return states.FAIR
				-1: #if facing left in the air
					if Input.is_action_pressed("left_%s" % id):
						parent.fr()
						return states.FAIR
					if Input.is_action_pressed("right_%s" % id):
						parent.fr()
						return states.BAIR
			parent.fr()
			return states.NAIR
		
		states.NAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('NAIR')
				parent.NAIR()
			if parent.NAIR() == true:
				parent.lag_frames = 0
				parent.fr()
				return states.AIR
			elif parent.frame < 5:
				parent.lag_frames = 0
			elif parent.frame > 15:
				parent.lag_frames = 0
			else: #otherwise if the attack is not finished
				parent.lag_frames = 7 
		
		states.UAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('UAIR')
				parent.UAIR()
			if parent.UAIR() == true:
				parent.lag_frames = 0
				parent.fr()
				return states.AIR
			else: #otherwise if the attack is not finished
				parent.lag_frames = 13
			
		states.DAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('DAIR')
				parent.DAIR()
			if parent.DAIR() == true:
				parent.lag_frames = 0
				parent.fr()
				return states.AIR
			else: #otherwise if the attack is not finished
				parent.lag_frames = 18
			
		states.BAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print('BAIR')
				parent.BAIR()
			if parent.BAIR() == true:
				parent.lag_frames = 0
				parent.fr()
				return states.AIR
			else: #otherwise if the attack is not finished
				parent.lag_frames = 7 
					
		states.FAIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0: #player can jump out of forward air attack
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR
			if parent.frame == 0:
				print('FAIR')
				parent.FAIR()
			if parent.FAIR() == true:
				parent.lag_frames = 30
				parent.fr()
				return states.FAIR
			else: #otherwise if the attack is not finished
				parent.lag_frames = 18 
		
		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent.fr()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s" % id):
				parent.fr()
				return states.DOWN_TILT
			if Input.is_action_pressed("left_%s" % id):
				parent.turn(true)
				parent.fr()
				return states.FORWARD_TILT
			if Input.is_action_pressed("right_%s" % id):
				parent.turn(false)
				parent.fr()
				return states.FORWARD_TILT
			parent.fr()
			return states.JAB
			
		states.FORWARD_TILT:
			if parent.frame == 0:
				parent.forward_swing()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.forward_swing() == true:
				if Input.is_action_pressed("right_%s" % id):
					parent.fr()
					return states.RUN
				elif Input.is_action_pressed("left_%s" % id):
					parent.fr()
					return states.RUN
				else:
					parent.fr()
					return states.STAND
		
		states.UP_TILT:
			if parent.frame == 0:
				parent.up_swing()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION*2
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION*2
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.up_swing() == true:
				if Input.is_action_pressed("up_%s" % id):
					parent.fr()
					return states.STAND
				else:
					parent.fr()
					return states.STAND
		
		states.DOWN_TILT:
			if parent.frame == 0:
				parent.down_swing_1()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.down_swing_1() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.fr()
					return states.CROUCH
				else:
					parent.fr()
					return states.STAND
					
		states.JAB:
			pass
			
		states.NEUTRAL_SPECIAL:
			if AIREAL() == false:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x = parent.velocity.x - parent.TRACTION * 10
					parent.velocity.x = clampi(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x = parent.velocity.x + parent.TRACTION * 10
					parent.velocity.x = clampi(parent.velocity.x,parent.velocity.x,0)
					
			if AIREAL() == true:
				AIRMOVEMENT()
			if parent.frame <= 1:
				if parent.projectile_cooldown == 1:
					parent.projectile_cooldown =- 1
				if parent.projectile_cooldown == 0:
					parent.projectile_cooldown += 1
					parent.fr()
					parent.NEUTRAL_SPECIAL()
			if parent.frame < 14:
				if Input.is_action_just_pressed("special_%s" % id):
					parent.fr()
					return states.NEUTRAL_SPECIAL
			if parent.NEUTRAL_SPECIAL() == true:
				if AIREAL() == true:
					return states.AIR
				if AIREAL() == false:
					if parent.frame == 14:
						parent.fr()
						return states.STAND
		
		states.HIT_FREEZE:
			if parent.freezeframes == 0:
				parent.fr()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.hdecay = hd
				parent.vdecay = vd
				return states.HITSTUN
			parent.position = pos
		
		states.HITSTUN:
			#print(" YVelocity at start of hitstun state: " + str(parent.velocity.y))
			if parent.knockback >= 3: #if knockback is large enough, you can bounce off of surfaces
				var bounce = parent.move_and_collide(parent.velocity *delta)
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.get_normal()) * .8
					parent.hitstun = round(parent.hitstun * .8)
					#print("bounce initiated")
					
			if parent.velocity.y < 0: #if player is moving up
				parent.velocity.y += (parent.vdecay)*0.5 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y,parent.velocity.y,0)
				
			if parent.velocity.x < 0: #if player is moving left
				parent.velocity.x += (parent.hdecay)*0.4 * -1 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
				#print("x velocity: " + str(parent.velocity.x))
			elif parent.velocity.x > 0: #if player is moving right
				parent.velocity.x -= parent.hdecay*0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				#print("x velocity: " + str(parent.velocity.x))
				
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent.fr()
					return states.AIR
				else:
					parent.fr()
					return states.AIR
			elif parent.frame > 60*5:
				return states.AIR

func enter_state(new_state, old_state): #Once you have entered a state, play the aproporiate animation
	match new_state:
		states.STAND: 
			parent.sprite.play("Idle")
			parent.states.text = str("STAND")
		states.DASH:
			parent.sprite.play("Run")
			parent.states.text = str("DASH")
		states.TURN:
			#parent.sprite.play("Turn")
			parent.states.text = str("TURN")
		states.CROUCH:
			#parent.sprite.play("Crouch)
			parent.states.text = str("CROUCH")
		states.WALK:
			parent.sprite.play("Walk")
			parent.states.text = str("WALK")
		states.RUN:
			parent.sprite.play("Run")
			parent.states.text = str("RUN")
		states.JUMP_SQUAT:
			parent.states.text = str("JUMP_SQUAT")
		states.SHORT_HOP:
			parent.sprite.play("Jump")
			parent.states.text = str("SHORT_HOP")
		states.FULL_HOP:
			parent.sprite.play("Jump")
			parent.states.text = str("FULL_HOP")
		states.AIR:
			parent.sprite.play("Jump")
			parent.states.text = str("AIR")
		states.LANDING:
			#parent.play_animation("Crouch")
			parent.states.text = str("LANDING")
			
		states.LEDGE_CATCH:
			#parent.sprite.play("LEDGE_CATCH")
			parent.states.text = str("LEDGE_CATCH")
		states.LEDGE_HOLD:
			#parent.sprite.play("LEDGE_HOLD")
			parent.states.text = str("LEDGE_HOLD")
		states.LEDGE_CLIMB:
			#parent.sprite.play("LEDGE_ROLL")
			parent.states.text = str("LEDGE_CLIMB")
		states.LEDGE_JUMP:
			#parent.sprite.play("LEDGE_JUMP")
			parent.states.text = str("LEDGE_JUMP")
		states.LEDGE_ROLL:
			#parent.sprite.play("LEDGE_ROLL")
			parent.states.text = str("LEDGE_ROLL")
			
		states.AIR_ATTACK:
			parent.states.text = str("AIR_ATTACK")
		states.NAIR:
			parent.states.text = str("NAIR")
			parent.sprite.play("Attack_One")
		states.UAIR:
			parent.states.text = str("UAIR")
			parent.sprite.play("Attack_Three")
		states.DAIR:
			parent.states.text = str("DAIR")
		states.FAIR:
			parent.states.text = str("FAIR")
			parent.sprite.play("Attack_One")
		states.BAIR:
			parent.states.text = str("BAIR")
			
		states.GROUND_ATTACK:
			parent.states.text = str("GROUND_ATTACK")
		states.FORWARD_TILT:
			parent.states.text = str("FORWARD_TILT")
			parent.sprite.play("Attack_One")
		states.DOWN_TILT:
			parent.states.text = str("DOWN_TILT")
			parent.sprite.play("Attack_Two")
		states.UP_TILT:
			parent.states.text = str("UP_TILT")
			parent.sprite.play("Attack_Three")
		states.JAB:
			parent.states.text = str("JAB")
			#parent.sprite.play("Jab")
		states.NEUTRAL_SPECIAL:
			parent.states.text = str("NEUTRAL_SPECIAL")
		states.HIT_FREEZE:
			parent.states.text = str("HITFREEZE")
			parent.sprite.play("Hurt")
		states.HITSTUN:
			parent.states.text = str("HITSTUN")
			parent.sprite.play("Hurt")
			
func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func AIRMOVEMENT():
	if parent.velocity.y < parent.FALLINGSPEED: #If vert velocity is less than the FALLSPEED, increase vert velocity 
		parent.velocity.y += parent.FALLSPEED #In GoDot, positive y is inverted, so + to y, is down
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall: 
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true: #if we are fast falling
		parent.set_collision_mask_value(2,false) #character will be able to fall through platforms
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
	#print("GroundL:", parent.GroundL.is_colliding(), " GroundR:", parent.GroundR.is_colliding(), " VelY:", parent.velocity.y)
	if state_includes([states.AIR,states.NAIR,states.DAIR,states.FAIR,states.BAIR,states.UAIR]): #if the character is withing any of the provided states (within state_includes)
		if(parent.GroundL.is_colliding()) and parent.velocity.y >= -5: #and parent.velocity.y > 0 #if the characters left foot is touching the ground and its vert velocity is greater than 0
			#var collider = parent.GroundL.get_collider() #store what the foot is colliding with
			
			var col_pointL = parent.GroundL.get_collision_point()
			var col_normL = parent.GroundR.get_collision_normal() 
			var offset = 60
			var new_pos = col_pointL.y - offset
			parent.position.y = new_pos
			
			parent.frame = 0 #reset frame count
			if parent.velocity.y > 0: 
				parent.velocity.y = 0 #reset vert velocity
			parent.fastfall = false #end the fastfall because we are now on the ground
			return true
			
		elif parent.GroundR.is_colliding() and parent.velocity.y >= -5:# and parent.velocity.y > 0: #if the characters right foot is touching the ground and its vert velocity is greater than zer0
			#var collider2 = parent.GroundR.get_collider() #store what the foot is colliding with
			
			var col_pointR = parent.GroundR.get_collision_point()
			var col_normR = parent.GroundR.get_collision_normal()
			var offset2 = 60
			var new_pos2 = col_pointR.y - offset2
			parent.position.y = new_pos2
			
			parent.frame = 0 #reset frame count
			if parent.velocity.y > 0: 
				parent.velocity.y = 0 #reset vert velocity
			parent.fastfall = false #end the fastfall because we are now on the ground
			return true

func FALLING():
	if state_includes([states.STAND, states.DASH]): #if the character is withing any of the provided states (within state_includes)
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():	
			#print("Falling is true")
			return true #if neither of the characters feet are touching the ground, it is falling(return true)
		#print("Falling is false")
		return false

func Ledge():
	if state_includes([states.AIR]):
		if parent.GrabF.is_colliding():
			var collider = parent.GrabF.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.fr()
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				self.parent.position.y = collider.position.y - 1
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.fr()
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20
				self.parent.position.y = collider.position.y + 1
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
		if parent.GrabB.is_colliding():
			var collider = parent.GrabB.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.fr()
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				self.parent.position.y = collider.position.y - 1
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.fr()
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20
				self.parent.position.y = collider.position.y + 1
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true

func TILT():
	if state_includes([states.STAND, states.DASH, states.RUN, states.WALK, states.CROUCH]):
		return true

func SPECIAL():
	if state_includes([states.STAND, states.WALK, states.DASH, states.RUN, states.CROUCH]):
		return true

func AIREAL():
	if state_includes([states.AIR, states.DAIR, states.NAIR, states.FAIR, states.BAIR, states.UAIR, states.NEUTRAL_SPECIAL]):
		if !(parent.GroundL.is_colliding()) and !(parent.GroundR.is_colliding()):
			return true
		else:
			return false
	else:
		return false

var kbx
var kby
var hd
var vd
var pos

func hitfreeze(duration, knockback):
	pos = parent.get_position()
	parent.freezeframes = duration
	kbx = knockback[0]
	kby = knockback[1]
	hd = knockback[2]
	vd = knockback[3]
