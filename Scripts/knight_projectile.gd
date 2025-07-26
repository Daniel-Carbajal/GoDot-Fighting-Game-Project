extends Area2D

@export var LASER_SPEED = 1500
@export var parent = get_parent()
@export var duration = 60
@export var damage = 5

var frame = 0
var dir_x = 1
var dir_y = 0
var player_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	player_list.append(parent)
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame += floor(delta * 60)
	if frame >= duration:
		queue_free()
	var motion = (Vector2(dir_x,dir_y)).normalized()*LASER_SPEED
	set_position(get_position()+motion*delta)
	position.direction_to(motion)
	
	set_rotation_degrees(rad_to_deg(Vector2(dir_x,dir_y).angle()))
	
func dir(dx, dy):
	dir_x = dx
	dir_y = dy
		
func _on_knight_projectile_body_entered(body):
	if not (body in player_list):
		#print('hit')
		body.percentage += damage
		queue_free()

