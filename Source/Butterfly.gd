extends KinematicBody2D

var velocity : Vector2 = Vector2.ZERO
var gravity = Vector2(0, 150)
var drag = 0.05

var flapSpeed = 80
var flapLerpCoefficient = 0.5
var flapDir = Vector2()

var flyThrough : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("Resting")
	$AnimatedSprite.speed_scale = 4 / $FlapTimer.wait_time
	pass # Replace with function body.

func _physics_process(delta):
	if $Area2D.get_overlapping_bodies().empty():
		flyThrough = Input.is_action_pressed("flyThrough")
	else: #only enable flyThrough, never disable it
		flyThrough = flyThrough || Input.is_action_pressed("flyThrough")
	$CollisionShape2D.disabled = flyThrough
	
	velocity += gravity * delta
	velocity *= (1-drag)
	
	var dir = get_direction()
	if canFlap() and dir.length_squared() != 0:
		flapDir = dir
		if flapDir.x > 0:
			$AnimatedSprite.flip_h = false
		if flapDir.x < 0:
			$AnimatedSprite.flip_h = true
		#DDD.DrawRay(self.global_position, flapDir*50, Color(0, 0, 1), 2)
		$FlapTimer.start()
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("Flap")
	#If flapping go to direction
	if isFlapping():
		velocity = lerp(velocity, flapDir*flapSpeed, flapLerpCoefficient)
		pass
	else:
		$AnimatedSprite.stop()
	
	#self.global_position += velocity * delta
	#velocity = move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(80))
	var collision : KinematicCollision2D = move_and_collide(velocity * delta, true, true, true)
	if collision:
		if collision.normal.dot(Vector2.DOWN) > 0: # hit a ceiling
			velocity = velocity - collision.normal * collision.normal.dot(velocity)
		elif collision.normal.dot(Vector2.DOWN) < - cos(deg2rad(85)): #hit floor
			velocity = Vector2.ZERO
			if $AnimatedSprite.playing == false: #Only change to rest if flap is done
				$AnimatedSprite.play("Rest")
				#Flip on very inclined slopes
				if collision.normal.dot(Vector2.LEFT) > cos(deg2rad(70)):
					$AnimatedSprite.flip_h = false
				if collision.normal.dot(Vector2.RIGHT) > cos(deg2rad(70)):
					$AnimatedSprite.flip_h = true
			pass
	move_and_collide(velocity * delta)
	
func get_direction() -> Vector2 :
	var dir = Vector2(0, 0)
	var sideFlapDeg = 10
	var R_vec = Vector2(cos(deg2rad(sideFlapDeg)), - sin(deg2rad(sideFlapDeg)))
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
