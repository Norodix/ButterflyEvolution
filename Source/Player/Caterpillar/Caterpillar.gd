extends KinematicBody2D

# Caterpillar motion script
const StepSize = 3 #determines the speed of the caterpillar, in normal motion: speed = stepsize * fps
const stepTolerance = 2
const headStepSize = 2
var headHeight = 9
var pastSteps = Array()
var segmentNum = 6 #number of in-between segments (without head and tail)
var segments
const segmentDistance = 12
onready var segmentStepDelta = round(float(segmentDistance)/float(StepSize)) #how many steps are between segments
onready var legPhaseStep = 1.0/(2.0*float(segmentDistance)) #how much the legs phase moves for each step
var isHeadLifted : bool = false
var anchorSegment = 4

var fullness : int = 0
var metamorphosisFullness : int = 6
var metamorphosisStarted : bool = false
signal despawn

class Step:
	var valid : bool = false
	var position : Vector2 = Vector2()
	var normal : Vector2 = Vector2(0, 1)
	var dir : Vector2 = Vector2(1, 0)
	var legPhase = 0.5
	
	func isFlipped():
		var dir3D = Vector3(self.dir.x, self.dir.y, 0)
		var nor3D = Vector3(self.normal.x, self.normal.y, 0)
		var is_flipped : bool =  dir3D.cross(nor3D).z > 0
		return is_flipped

func _ready():
	GlobalProperties.PlayerMaxFullness = metamorphosisFullness
	#add identical segments to 1st
	for i in range(segmentNum - 1):
		$Segments.add_child_below_node($Segments.get_child(0), $Segments.get_child(0).duplicate())
	segments = $Segments.get_children()
	for i in range(segmentStepDelta * segments.size()):
		var emptyStep = Step.new()
		emptyStep.position = self.global_position
		pastSteps.append(emptyStep)
	$Segments.set_as_toplevel(true)
	#Colorize the caterpillar randomly
	var c = pickRandomColor()
	#print(c)
	for segment in segments:
		segment.modulate = c
	$Head.modulate = c
	
func _physics_process(delta):
	if metamorphosisStarted:
		self.fullness = 0
		pastSteps.append(pastSteps[-1])
		while pastSteps.size() > segmentStepDelta * segments.size():
			pastSteps.remove(0)
		if pastSteps[0] == pastSteps[-1]:
			self.emit_signal("despawn")
		updateSegmentPositions()
		return
	
	var dir = get_direction()
	#DDD.DrawLine(self.global_position, self.global_position + dir * 50, Color(1.0, 0, 0))
	if Input.is_action_pressed("LiftHead"):
		isHeadLifted = true

	if isHeadLifted:
		#move head around
		#Use pastSteps's ith section position as anchor
		var anchorIndex = -1 - segmentStepDelta * anchorSegment
		var anchorPoint = pastSteps[anchorIndex].position
		var reach = (abs(anchorIndex) - 1) * StepSize
		#move head toward direction
		self.global_position += dir * headStepSize
		#snap back to proper distance from anchor
		var head_from_anchor = self.global_position - anchorPoint
		if head_from_anchor.length() > reach:
			self.global_position = anchorPoint + head_from_anchor.normalized() * reach
		head_from_anchor = self.global_position - anchorPoint #update after snapping
		var headDir = head_from_anchor.normalized()
		pastSteps[-1].dir = headDir
		#normal should point up, perpendicular to dir
		pastSteps[-1].normal = (Vector2.UP - Vector2.UP.dot(headDir)*headDir.normalized()).normalized()
		#DDD.DrawRay(self.global_position, pastSteps[-1].normal*20, Color(0, 1, 1))
		#DDD.DrawRay(self.global_position, pastSteps[-1].dir*20, Color(1, 1, 0))
		
		
		#### do FABRIK here to move the last anchorSegment segments ####
		var stepIndexes = range(anchorIndex + 1, 0)
		#[-15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1]
		for ps in stepIndexes:
			pastSteps[stepIndexes[ps]].position = anchorPoint + head_from_anchor * (ps-anchorIndex) / stepIndexes.size()
			pastSteps[stepIndexes[ps]].normal = pastSteps[-1].normal
			pastSteps[stepIndexes[ps]].dir = pastSteps[-1].dir
		####################################################
		
		#try to snap to closest object when not overlapping with other one currently
		if not Input.is_action_pressed("LiftHead"):
			if $Area2D.get_overlapping_bodies().empty():
				var ray = get_closest_ray(self.global_position, headHeight + headStepSize)
				if not ray.empty():
					isHeadLifted = false
				pass

	elif dir.length() != 0: #Head is not lifted, try normal crawling
		var nextStep = get_next_step(dir)
		if nextStep.valid:
			#Draw the normal
			#DDD.DrawLine(self.global_position, nextStep.normal * 30 + self.global_position, Color(0, 1, 1))
			#Draw the step direction
			#DDD.DrawLine(self.global_position, nextStep.dir * 20 + self.global_position, Color(1, 0, 0))
			#check if too close to the previous step
			if (nextStep.position - pastSteps[-1].position).length() < float(StepSize)/10.0:
				#print("TOOCLOSE")
				pass
			else:
				#record the step in past steps
				pastSteps.append(nextStep)
				#Animate the first leg, others will follow
				pastSteps[-1].legPhase = pastSteps[-2].legPhase + legPhaseStep
			#keep the past steps to necessary size
			while pastSteps.size() > segmentStepDelta * segments.size():
				pastSteps.remove(0)
			self.move_and_slide((nextStep.position - self.global_position) * 60)
	
	#set the rotation according to dir and normal
	self.global_rotation = pastSteps[-1].normal.angle() + PI/2
	#check normal and dir agains each other to determine if flip is needed
	$Head.flip_h = pastSteps[-1].isFlipped()
	
	updateSegmentPositions()

func updateSegmentPositions():
	for segment in segments:
		var i = segment.get_index()
		var segmentStep = pastSteps[-((i+1)*segmentStepDelta)]
		segment.global_position = segmentStep.position
		segment.global_rotation = segmentStep.normal.angle() + PI/2
		if segmentStep.isFlipped():
			segment.scale.x = - abs(segment.scale.x)
		else:
			segment.scale.x = abs(segment.scale.x)
		#segment.get_child(0).get_child(0).unit_offset = segmentStep.legPhase
		segment.get_node("Path2D/PathFollow2D").unit_offset = segmentStep.legPhase

func _process(delta):
	if $EatCooldown.is_stopped():
		if Input.is_action_pressed("Eat"):
			var food = $EatArea.get_overlapping_areas()
			if not food.empty():
				var foodValue = food[0].bite()
				fullness += foodValue
				fullness = clamp(fullness, 0, metamorphosisFullness)
				$EatCooldown.start()
	GlobalProperties.PlayerFullness = fullness
	
	if Input.is_action_just_pressed("Metamorphosis"): #Player wants to transform
		var upsidedown =  pastSteps[-1].normal.dot(Vector2.DOWN) > 0.1
		var full = fullness >= metamorphosisFullness
		if upsidedown and full:
			metamorphosisStarted = true			

func get_direction() -> Vector2 :
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return dir.clamped(1)

func get_closest_ray(from: Vector2, length: float) -> Dictionary:
	var ss = get_world_2d().direct_space_state
	var closestRay = Dictionary()
	var minDistance : float = length * 2
	for deg in range(360):
		var a = deg2rad(deg)
		var target = Vector2(cos(a), sin(a)) * length + from
		var ray = ss.intersect_ray(from, target)
		if not ray.empty():
			var distance = (ray.position - from).length()
			if distance < minDistance:
				closestRay = ray
				minDistance = distance
	return closestRay

func get_next_step(dir : Vector2) -> Step:
	# find the next step where the head should move
	var step = Step.new()
	step.valid = false
	step.position = self.global_position
	
	if dir.length() == 0:
		return step
		
	var dir_a = dir.angle()
	var ss = get_world_2d().direct_space_state
	var start1 = self.global_position
	var start2 = start1 + StepSize * dir
	
	var ray_starts = []
	var ray_ends = []
	var angleArray = []
	for a in range(0, 360, 1):
		ray_starts.append(start1)
		ray_ends.append(start1 +  Vector2(cos(a), sin(a)) * (StepSize + headHeight)*2)
#		ray_starts.append(start2)
#		ray_ends.append(start2 +  Vector2(cos(a), sin(a)) * (StepSize + headHeight)*2)
		
	var validSteps = []
	var normals = []
	
	for r in ray_starts.size():
		#intersect all rays
		var ray = ss.intersect_ray(ray_starts[r], ray_ends[r])
		#DDD.DrawLine(start, start + (end-start) * 50, Color(0, 1, 0))
		#DDD.DrawLine(start, end, Color(0, 1, 0))
		if not ray.empty():
			#get normal to the surface
			var newHeadPosition = ray.position + ray.normal * headHeight
			#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 0, 1))
			var stepDistance = (newHeadPosition - self.global_position).length()
			var stepDelta = abs(stepDistance - StepSize)
			if stepDelta < stepTolerance:
				#step is valid size, check direction
				if (newHeadPosition - self.global_position).normalized().dot(dir.normalized()) > 0.3:
					#step is in the general direction of dir
					validSteps.append(newHeadPosition)
					normals.append(ray.normal) # collect the normals for later use
					#DDD.DrawLine(ray.position, newHeadPosition, Color(0, 1, 1), 3) #draw fully valid rays
	
	if validSteps.size() == 0:
		return step
	
	#check and average the valid steps, if the average is valid still, do it
	var average = Vector2()
	var averageNormal = Vector2()
	for i in validSteps.size():
		average += validSteps[i]
		averageNormal += normals[i]
	average /= validSteps.size()
	averageNormal /= validSteps.size()
	var stepDistance = (average - self.global_position).length()
	var stepDelta = abs(stepDistance - StepSize)
	if stepDelta < stepTolerance:
		#average step is valid, set properties here
		#step.position = self.global_position + (average-self.global_position) * dir.length()
		step.position = average
		step.valid = true
		step.normal = averageNormal.normalized()
		step.dir = (step.position - self.global_position).normalized()
		return step
	
	return step #return invalid step in case of problem
	pass

func pickRandomColor():
	randomize()
	var hue = randf()
	var sat = 0.6 + randf()*0.2
	var val = 0.6 + randf()*0.2
	return Color().from_hsv(hue, sat, val)
