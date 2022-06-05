extends KinematicBody2D

var FlapAnimationFrameCount = 4

var velocity : Vector2 = Vector2.ZERO
var gravity = Vector2(0, 150)
var drag = 0.05

var flapSpeed = 200
var flapLerpCoefficient = 0.5
var flapDir = Vector2()

var contSpeed = 160
var contLerpCoefficient = 0.1

var flyThrough : bool = false
var mate = null
var restTimer = 0.0
var restTimeDespawn = 1.5

var resting : bool = false
var metamorphosisStarted : bool = false

var gradient : Gradient
var hue = 0.0; # hue of the player
var sat = 0.7
var val = 0.8

signal despawn

# Called when the node enters the scene tree for the first time.
func _ready():
	hue = GlobalProperties.PlayerHue
	gradient = Gradient.new()
	gradient.set_offset(1, 0.66)
	gradient.add_point(0.3, Color.from_hsv(hue, sat, val))
	$AnimatedSprite.material.get_shader_param("colorCurve").gradient = gradient
	
	$AnimatedSprite.play("Resting")
	$AnimatedSprite.speed_scale = FlapAnimationFrameCount / $FlapTimer.wait_time
	
	mate = null
	
func _process(delta):
	if Input.is_action_just_pressed("Metamorphosis"):
		if resting and mate:
			metamorphosisStarted = true
			$DespawnTimer.start()

func _physics_process(delta):
	if metamorphosisStarted:
		var s = lerp(1.0, 0.1, 1 - $DespawnTimer.time_left/$DespawnTimer.wait_time)
		self.scale = Vector2(s, s)
		if $DespawnTimer.is_stopped():
			GlobalProperties.PlayerHue = mixHue(GlobalProperties.PlayerMate.hue, self.hue)
			emit_signal("despawn")
			GlobalProperties.PlayerMate = null
		return
	
	if Input.is_action_just_pressed("Mate"):
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
	
	var collision : KinematicCollision2D = move_and_collide(velocity * delta, true, true, true)
	if collision:
		if collision.normal.dot(Vector2.DOWN) > 0: # hit a ceiling
			velocity = velocity - collision.normal * collision.normal.dot(velocity) #Only move along ceiling
		elif collision.normal.dot(Vector2.DOWN) < - cos(deg2rad(85)): #hit floor
			velocity = Vector2.ZERO
			resting = true
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

	if velocity.length_squared() > 10:
		resting = false	
	
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
		#find closest mate
		var minDist = 99999
		var minDistMate = null
		for m in mates: 
			var d = (m.global_position - self.global_position).length()
			if d < minDist:
				minDist = d
				minDistMate = m.get_parent().get_parent()
		$HeartParticle.emitting = true
		mate = minDistMate
		GlobalProperties.PlayerMate = minDistMate

func mixHue(a, b):
	var vec_a = Vector2(cos(a * PI * 2), sin(a * PI * 2))
	var vec_b = Vector2(cos(b * PI * 2), sin(b * PI * 2))
	var vec_c = (vec_a + vec_b).normalized()
	var ang = vec_c.angle()
	ang = fmod(ang+PI*2, PI*2)
	return (ang / (2 * PI))
