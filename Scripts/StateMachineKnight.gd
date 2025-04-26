extends StateMachine
@export var id = 1

func _ready():
	pass

func state_logic(delta):
	pass

func get_transition(delta):
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
