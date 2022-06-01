extends KinematicBody2D

var velocity : Vector2 = Vector2.ZERO
var gravity = Vector2(0, 150)
var drag = 0.05

var flapSpeed = 80
var flapLerpCoefficient = 0.5
var flapDir = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Butterfly ready")
	pass # Replace with function body.

func _physics_process(delta):
	velocity += gravity * delta
	velocity *= (1-drag)
	
	var dir = get_direction()
	if canFlap() and dir.length_squared() != 0:
		flapDir = dir
		DDD.DrawRay(self.global_position, flapDir*50, Color(0, 0, 1), 2)
		$FlapTimer.start()
	#If flapping go to direction
	if isFlapping():
		velocity = lerp(velocity, flapDir*flapSpeed, flapLerpCoefficient)
		pass
	
	#self.global_position += velocity * delta
	move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(80))
	
func get_direction() -> Vector2 :
	var dir = Vector2(0, 0)
	var R_vec = Vector2(cos(deg2rad(30)), - sin(deg2rad(30)))
	var L_vec = Vector2( - R_vec.x, R_vec.y)
	var U_vec = Vector2(0, -1)
	var r = int(Input.is_action_pressed("ui_right"))
	var l = int(Input.is_action_pressed("ui_left"))
	var u = int(Input.is_action_pressed("ui_up"))
	dir = r*R_vec + l*L_vec + u*U_vec
	return dir.normalized()


func canFlap():
	return $FlapCooldown.is_stopped() and $FlapTimer.is_stopped()
	
func isFlapping():
	return not $FlapTimer.is_stopped()


func _on_FlapCooldown_timeout():
	pass # Replace with function body.


func _on_FlapTimer_timeout():
	$FlapCooldown.start()
	pass # Replace with function body.
