extends Node2D

class Line:
	var Start
	var End
	var LineColor
	var Time
	var Drawn
	
	func _init(Start, End, LineColor, Time):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.Time = Time
		self.Drawn = false

var Lines = []
var RemovedLine = false

func _ready():
	self.z_index = 100

func _process(delta):
	for i in range(len(Lines)):
		Lines[i].Time -= delta
	
	if Lines.size() > 0:
		update()
	

func _draw():
	#Remove lines that have timed out and have been drawn already
	var j = Lines.size() - 1
	while (j >= 0):
		if(Lines[j].Time < 0.0 && Lines[j].Drawn):
			Lines.remove(j)
			RemovedLine = true
		j -= 1	


	for i in range(len(Lines)):
		#var ScreenPointStart = get_viewport_transform() * (get_global_transform() * Lines[i].Start)
		#var ScreenPointEnd = get_viewport_transform() * (get_global_transform() * Lines[i].End)
		var ScreenPointStart = Lines[i].Start
		var ScreenPointEnd = Lines[i].End
		
		
		draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor)
		Lines[i].Drawn = true
	


func DrawLine(Start, End, LineColor, Time = 0.0):
	Lines.append(Line.new(Start, End, LineColor, Time))

func DrawRay(Start, Ray, LineColor, Time = 0.0):
	Lines.append(Line.new(Start, Start + Ray, LineColor, Time))

func DrawCube(Center, HalfExtents, LineColor, Time = 0.0):
	#Start at the 'top left'
	var LinePointStart = Center
	LinePointStart.x -= HalfExtents
	LinePointStart.y += HalfExtents
	LinePointStart.z -= HalfExtents
	
	#Draw top square
	var LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw bottom square
	LinePointStart = LinePointEnd + Vector3(0, -HalfExtents * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, Time);
	
	#Draw vertical lines
	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(0, 0, HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(HalfExtents * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
	LinePointStart += Vector3(0, 0, -HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, Time)
