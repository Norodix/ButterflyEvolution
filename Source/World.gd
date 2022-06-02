extends Node2D

var caterpillarScenePath = "res://Caterpillar.tscn"
var butterflyScenePath = "res://Butterfly.tscn"

var caterpillarNode : Node2D
var butterflyNode : Node2D
var playerLocation : Vector2 = Vector2(600, 0)

onready var cam = $CameraFocusNode

func _ready():
	playerLocation = $SpawnLocation.global_position
	$CameraFocusNode.global_position = playerLocation
	$CameraFocusNode/Camera2D.global_position = playerLocation
	#spawn_butterfly()
	spawn_caterpillar()
	randomize()
	pass 

func _process(delta):
	cam.global_position = get_player_location()
	if Input.is_key_pressed(KEY_C):
		spawn_caterpillar()
	if Input.is_key_pressed(KEY_B):
		spawn_butterfly()

func spawn_caterpillar():
	despawn()
	caterpillarNode = load(caterpillarScenePath).instance()
	caterpillarNode.global_position = playerLocation
	add_child(caterpillarNode)
	pass
	
func spawn_butterfly():
	despawn()
	butterflyNode = load(butterflyScenePath).instance()
	butterflyNode.global_position = playerLocation
	add_child(butterflyNode)
	pass

func despawn():
	if caterpillarNode in self.get_children():
		playerLocation = caterpillarNode.global_position
		remove_child(caterpillarNode)
	if butterflyNode in self.get_children():
		playerLocation = butterflyNode.global_position
		remove_child(butterflyNode)

func get_player_location() -> Vector2:
	var loc = Vector2()
	if caterpillarNode in self.get_children():
		loc = caterpillarNode.global_position
	if butterflyNode in self.get_children():
		loc = butterflyNode.global_position
	return loc
