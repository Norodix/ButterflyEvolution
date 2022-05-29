extends KinematicBody2D

# Caterpillar motion script
var StepSize = 3 #determines the speed of the caterpillar, in normal motion: speed = stepsize * fps
var headHeight = 20

class Step:
	var valid : bool = false
	var position : Vector2 = Vector2()

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

func _physics_process(delta):
	var dir = get_direction()
	#DDD.DrawLine(self.global_position, self.global_position + dir * 50, Color(1.0, 0, 0))
	if dir.length() != 0:
		var nextStep = get_next_step(dir)
		if nextStep.valid:
			self.move_and_collide(nextStep.position - self.global_position)
			#self.global_position = nextStep.position
	pass

func get_direction() -> Vector2 :
	var dir = Vector2(0, 0)
	var r = Input.is_action_pressed("ui_right")
	var l = Input.is_action_pressed("ui_left")
	var u = Input.is_action_pressed("ui_up")
	var d = Input.is_action_pressed("ui_down")
	dir.x = int(r) - int(l)
	dir.y = int(d) - int(u)
	return dir


func get_next_step(dir : Vector2) -> Step:
	# starting from target direction in expanding, alternating angles:
	# find the next step where the head should move
	var step = Step.new()
	step.valid = false
	step.position = self.global_position
	
	if dir.length() == 0:
		return step
		
	var dir_a = dir.angle()
	var ss = get_world_2d().direct_space_state
	var start = self.global_position
	var end = start
	
	var angleArray = []
	for a in range(0, 180, 1):
		angleArray.append(- a)
		angleArray.append(a)
		
	var validSteps = []
	
	for degree in angleArray:
		var a = deg2rad(degree) + dir_a
		end = start +  Vector2(cos(a), sin(a)) * StepSize * 10
		#DDD.DrawLine(start, start + (end-start) * 50, Color(0, 1, 0))
		#DDD.DrawLine(start, end, Color(0, 1, 0))
		var ray = ss.intersect_ray(start, end)
		if not ray.empty():
			#get normal to the surface
			var newHeadPosition = ray.position + ray.normal * headHeight
			#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 0, 1))
			var stepDistance = (newHeadPosition - self.global_position).length()
			var stepDelta = abs(stepDistance - StepSize)
			#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 0, 1))
			if stepDelta < 1:
				#step is valid size, check direction
				if (newHeadPosition - self.global_position).dot(dir) > 0:
					#step is in the general direction of dir
					validSteps.append(newHeadPosition)
	
	#check and average the valid steps, if the average is valid still, do it
	if validSteps.size() == 0:
		return step
	var average = Vector2()
	for s in validSteps:
		average += s
	average /= validSteps.size()
	var stepDistance = (average - self.global_position).length()
	var stepDelta = abs(stepDistance - StepSize)
	if stepDelta < 1:
		#average step is valid
		step.position = average
		step.valid = true
		return step
	
	return step #return invalid step in case of problem
	pass
