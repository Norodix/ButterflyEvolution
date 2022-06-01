extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(NodePath) var PlayerNode
onready var player = get_node(PlayerNode)

# Called when the node enters the scene tree for the first time.
func _ready():
	player.add_child(self)
	pass # Replace with function body.


func _process(delta):
	if get_parent() != player:
		get_parent().remove_child(self)
		player.add_child(self)
#Track player
#	pass
