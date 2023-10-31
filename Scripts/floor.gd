extends CSGPolygon3D

var floorplanPrefab = preload("res://Subscenes/floorplan.tscn")

var minTransparency = 0.0
var maxTransparency = 0.8
var zoomVisibilityThreshold = 0.3

var originalColor

var zoom_percentage

var contextSwitchThreshold = 0.3

var hovering : bool = false

var occupancy = 0
var occupancyText

var ID

var dataObj
var data = 5

var floorplan


func _ready():
	originalColor = self.material.albedo_color
	var collider = get_node("Area3D").get_node("collision")
	collider.polygon = self.polygon
	collider.depth = self.depth
	collider.position[2] -= self.depth/2
	
	get_node("Area3D").mouse_entered.connect(self.mouseEnter)
	get_node("Area3D").mouse_exited.connect(self.mouseExit)
	get_node("Area3D").input_event.connect(self.clicked)
	
	dataObj = get_tree().get_root().get_node("Root").get_node("Data")
	data = dataObj.getData()
	
	occupancyText = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer").get_node("PanelContainer").get_node("OccupancyDisplay")

	var floorplanInst = floorplanPrefab.instantiate()
	floorplanInst.setRooms(data[ID]['children'])
	floorplanInst.name = "Floorplan"
	floorplanInst.hide()
	add_child(floorplanInst)
	floorplan = floorplanInst
	
	
	

func _process(delta):
	data = dataObj.getData()
	fetchOccupancy()
	zoom_percentage = get_tree().get_root().get_node("Root").get_node("MapView").get_node("Camera").getZoomPercentage()
	hoverActions()
	var scaled_zoom_percentage = 1 - (min((1/zoomVisibilityThreshold) * zoom_percentage, 1))
	# Scale transparency to min/max transparency window
	var objTransparency = minTransparency + (maxTransparency - minTransparency) * scaled_zoom_percentage
	self.material.albedo_color[3] = objTransparency
	
func mouseEnter():
	hovering = true
	
func mouseExit():
	hovering = false
	occupancyText.text = "Occupancy: " 
	
func clicked(a,b,c,d,e):
	if not b is InputEventMouseButton or b['button_index'] != 1 or b['button_mask'] != 1:
		return
	floorplan.show()
	
func _unhandled_input(event):
	if floorplan.is_visible() and event.is_action_pressed("escape"):
		floorplan.hide()
	
func hoverActions():
	if hovering:
		if zoom_percentage < contextSwitchThreshold:
			material.albedo_color = Color.RED
			occupancyText.text = "Occupancy: " + str(occupancy)
		else:
			material.albedo_color = originalColor
	else:
		material.albedo_color = originalColor
		
func fetchOccupancy():
	occupancy = data[ID]['occupancy']
		
func setID(id):
	ID = id
