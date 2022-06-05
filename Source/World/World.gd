extends Node2D

var caterpillarScenePath = "res://Player/Caterpillar/Caterpillar.tscn"
var butterflyScenePath = "res://Player/Butterfly/Butterfly.tscn"

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
	
	#Check if the player scored and if so, create a new target
	if modDistance(GlobalProperties.TargetHue, GlobalProperties.PlayerHue, 1.0) < 1.0/20.0:
		randomize()
		$AudioPointScore.play()
		GlobalProperties.PlayerScore += 1
		GlobalProperties.TargetHue += 0.5
		GlobalProperties.TargetHue += rand_range(-0.2, 0.2)
		GlobalProperties.TargetHue = fmod(GlobalProperties.TargetHue, 1.0)

func modDistance(a, b, mod):
	var d = abs(a-b)
	if d > mod/2:
		d -= mod/2
	return d

func spawn_caterpillar():
	despawn()
	caterpillarNode = load(caterpillarScenePath).instance()
	caterpillarNode.global_position = playerLocation
	add_child(caterpillarNode)
	caterpillarNode.connect("despawn", self, "spawn_butterfly")
	pass
	
func spawn_butterfly():
	despawn()
	butterflyNode = load(butterflyScenePath).instance()
	butterflyNode.global_position = playerLocation
	add_child(butterflyNode)
	butterflyNode.connect("despawn", self, "spawn_caterpillar")
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
