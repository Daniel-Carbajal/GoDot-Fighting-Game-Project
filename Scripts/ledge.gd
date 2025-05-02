extends Area2D

@export_enum("Left", "Right") var ledge_Side = "Left" 
@onready var label = $"Label"
@onready var collision = $"CollisionShape2D"
var is_grabbed = false

func _on_Ledge_body_exited(body):
	is_grabbed = false
	
func _ready():
	if ledge_Side == "Left":
		label.text = "Ledge_L"
	else:
		label.text = "Ledge_R"
