extends Camera2D


@onready var p1 = get_parent().get_node("KNIGHT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position = p1.position
