extends Area2D

@export_enum("Left", "Right") var ledge_Side = "Left" 
@onready var label = $"Label"
@onready var collision = $"CollisionShape2D"
@onready var grab_state = $"Grab_Label"
var is_grabbed = false

func _physics_process(delta):
	grab_state.text = str(is_grabbed)

func _on_Ledge_body_exited(body): #moniterable must be set to true and be able to collide with the player, so it can detect when a player enters it
	is_grabbed = false #so that two people can not grab THIS ledge at the same time
	
func _ready():
	if ledge_Side == "Left":
		label.text = "Ledge_L"
	else:
		label.text = "Ledge_R"
