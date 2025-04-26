extends Node
class_name StateMachine #New class and can inherit
 
var state = null : set = set_state
var previous_state = null
var states = {}
 
@onready var parent = get_parent()
 
func _physics_process(delta): #Runs every frame
	if state !=null: #if it has a state
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition) 
 
func state_logic(delta):    
	pass
 
func get_transition(delta):
	return null
 
func enter_state(new_state, old_state):
	pass
 
func exit_state(old_state, new_state):
	pass
 
func set_state(new_state): #
	previous_state = state
	state = new_state
	
	if previous_state !=null: #if a previous state existed, end it
		exit_state(previous_state, new_state)
	if new_state !=null: #if we do not yet have a new state, enter the new state
		enter_state(new_state, previous_state)
 
func add_state(state_name):
	states[state_name] = states.size()
