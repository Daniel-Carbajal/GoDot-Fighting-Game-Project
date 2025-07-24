extends Node

func hitstun(mod, duration):
	Engine.time_scale = mod/100
	print(str(mod))
	#Pauses for duration of hitlag duration
	await get_tree().create_timer(duration*Engine.time_scale).timeout #only pauses this function
	Engine.time_scale = 1
