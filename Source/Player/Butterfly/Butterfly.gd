extends KinematicBody2D

var FlapAnimationFrameCount = 4

var velocity : Vector2 = Vector2.ZERO
var gravity = Vector2(0, 150)
var drag = 0.05

var flapSpeed = 160
var flapLerpCoefficient = 0.5
var flapDir = Vector2()

var contSpeed = 160
var contLerpCoefficient = 0.1

var flyThrough : bool = false
var mate = null
var restTimer = 0.0
var restTimeDespawn = 1.5

signal despawn

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("Resting")
	$AnimatedSprite.speed_scale = FlapAnimationFrameCount / $FlapTimer.wait_time
	pass # Replace with function body.

func _physics_process(delta):
	find_mate()
	
	if $Area2D.get_overlapping_bodies().empty():
		flyThrough = Input.is_action_pressed("flyThrough")
	else: #only enable flyThrough, never disable it
		flyThrough = flyThrough || Input.is_action_pressed("flyThrough")
	$CollisionShape2D.disabled = flyThrough
	
	velocity += gravity * delta
	velocity *= (1-drag)
	
	#moveWithFlaps()
	moveContinous()
	
	#self.global_position += velocity * delta
	#velocity = move_and_slide(velocity, Vector2.UP, true, 4, deg2rad(80))
	var collision : KinematicCollision2D = move_and_collide(velocity * delta, true, true, true)
	if collision:
		if collision.normal.dot(Vector2.DOWN) > 0: # hit a ceiling
			velocity = velocity - collision.normal * collision.normal.dot(velocity) #Only move along ceiling
		elif collision.normal.dot(Vector2.DOWN) < - cos(deg2rad(85)): #hit floor
			velocity = Vector2.ZERO
			if $AnimatedSprite.frame == FlapAnimationFrameCount - 1: #Only change to rest if flap is done
				$AnimatedSprite.play("Rest") #land
				#Flip on very inclined slopes
				if collision.normal.dot(Vector2.LEFT) > cos(deg2rad(70)):
					$AnimatedSprite.flip_h = false
				if collision.normal.dot(Vector2.RIGHT) > cos(deg2rad(70)):
					$AnimatedSprite.flip_h = true
	
	move_and_collide(velocity * delta)
	
	#Change flip based on velocity
	var flip_hysteresis = 0.1
	if velocity.x > flip_hysteresis:
		$AnimatedSprite.flip_h = false
	if velocity.x < -flip_hysteresis:
		$AnimatedSprite.flip_h = true
	#Respawn logic
	if mate:
		restTimer += delta
	if velocity.length_squared() > 1:
		restTimer = 0
	if restTimer > restTimeDespawn:
		self.emit_signal("despawn")
	
	
func get_direction() -> Vector2 :
	var dir = Vector2(0, 0)
	var sideFlapDeg = 10
	var Side_vec = Vector2(cos(deg2rad(sideFlapDeg)), - sin(deg2rad(sideFlapDeg)))
	var Up_vec = Vector2(0, 1)
	
	var inputDir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	dir.x += inputDir.x * Side_vec.x
	dir.y += inputDir.y * Up_vec.y + Side_vec.y * abs(inputDir.x)
	return dir.clamped(1)

func canFlap():
	return $FlapCooldown.is_stopped() and $FlapTimer.is_stopped()
	
func isFlapping():
	return not $FlapTimer.is_stopped()

func moveWithFlaps():
	var dir = get_direction()
	if canFlap() and dir.length_squared() != 0:
		#DDD.DrawRay(self.global_position, flapDir*50, Color(0, 0, 1), 2)
		$FlapTimer.start()
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("Flap")
	#If flapping go to direction
	if isFlapping():
		velocity = lerp(velocity, dir*flapSpeed, flapLerpCoefficient)
		pass
	else:
		$AnimatedSprite.stop()

func moveContinous():
	var dir = get_direction()
	if dir.length_squared() >= 0.1:
		velocity = lerp(velocity, dir*contSpeed, contLerpCoefficient)
		$AnimatedSprite.play("Flap")
#	else:
#		if $AnimatedSprite.frame == FlapAnimationFrameCount - 1:
#			$AnimatedSprite.stop()

func _on_FlapCooldown_timeout():
	pass # Replace with function body.


func _on_FlapTimer_timeout():
	$FlapCooldown.start()
	pass # Replace with function body.

func find_mate():
	if mate:
		return
	var mates = $MateArea.get_overlapping_areas()
	if not mates.empty():
		mate = mates[0]
