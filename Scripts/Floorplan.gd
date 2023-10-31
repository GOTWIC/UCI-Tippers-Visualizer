extends Node2D

var mapImage = null

var rooms = null

var dataObj
var data

var roomsDrawn = false

var temp = preload("res://resources/CS3-FLR01.png")

func _ready():
	dataObj = get_tree().get_root().get_node("Root").get_node("Data")
	data = dataObj.getData()

	if rooms != []:
		drawRooms()
	
	
	
func _process(delta):
	data = dataObj.getData()
	if roomsDrawn:
		updateOccupancy()
	
	
func setRooms(roomIDs):
	rooms = roomIDs

func drawRooms():
	var contrl = Control.new()
	contrl.name = "Rooms"

	var sprite = get_node("Sprite")
	sprite.texture = temp
	var size = sprite.texture.get_size()
	
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	var xScalar = float(width/size[0])
	var yScalar = float(height/size[1])
	var scalar = min(xScalar, yScalar) * 0.9
	
	sprite.scale = Vector2(scalar,scalar)
	sprite.position = Vector2(width/2, height/2)
	
	var origin = Vector2((width - size[0]*scalar)/2, (height + size[1]*scalar)/2)
	
	sprite.scale = Vector2(0,0)
	var scale = 2
	
	
	for room in rooms:
		var poly = Polygon2D.new()
		var points = data[room]['location']

		for i in range(len(points)):
			points[i] = Vector2(origin[0] + points[i][0] * scale, origin[1] - points[i][1] * scale)
		poly.polygon = points
		poly.color = Color(0.4,0.4,0.8,0.7)
		var xAvg = 0
		var yAvg = 0
		for point in points:
			xAvg += point[0]
			yAvg += point[1]
		var centroid = Vector2(xAvg/float(len(points)), yAvg/float(len(points)))
		var label = Label.new()
		label.text = str(data[room]['occupancy'])
		label.name = "Label"
		poly.name = str(room)
		label.position = centroid - Vector2(10,7.5)
		label.size = Vector2(40,30)
		poly.add_child(label)
		contrl.add_child(poly)
		
	add_child(contrl)
	
	roomsDrawn = true
	
func updateOccupancy():
	for child in get_node("Rooms").get_children():
		child.get_node("Label").text = str(data[float(str(child.name))]['occupancy'])
