extends CSGPolygon3D

var minTransparency = 0.3
var maxTransparency = 1.0

var originalColor

var zoom_percentage

var contextSwitchThreshold = 0.3

var hovering : bool = false

var occupancy = 0
var occupancyText

var floors : Array = []

var ID

var dataObj
var data

func _ready():
	originalColor = self.material.albedo_color
	var collider = get_node("Area3D").get_node("collision")
	collider.polygon = self.polygon
	collider.depth = self.depth
	collider.position[2] -= self.depth/2
	
	get_node("Area3D").mouse_entered.connect(self.mouseEnter)
	get_node("Area3D").mouse_exited.connect(self.mouseExit)
	
	dataObj = get_tree().get_root().get_node("Root").get_node("Data")
	
	occupancyText = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer").get_node("PanelContainer").get_node("OccupancyDisplay")


func _process(delta):
	data = dataObj.getData()
	fetchOccupancy()
	zoom_percentage = get_tree().get_root().get_node("Root").get_node("MapView").get_node("Camera").getZoomPercentage()
	hoverActions()
	# Scale transparency to min/max transparency window
	var objTransparency = minTransparency + (maxTransparency - minTransparency) * zoom_percentage
	self.material.albedo_color[3] = objTransparency
	
func mouseEnter():
	hovering = true
	
func mouseExit():
	hovering = false
	occupancyText.text = "Occupancy: " 
	
func hoverActions():
	
	if zoom_percentage >= contextSwitchThreshold:
		get_node("Area3D").visible = true
		if hovering:
			material.albedo_color = Color.RED
			occupancyText.text = "Occupancy: " + str(occupancy)
		else:
			material.albedo_color = originalColor
			
	else:
		get_node("Area3D").visible = false
		material.albedo_color = originalColor
		
func fetchOccupancy():
	occupancy = data[ID]['occupancy']
	
func setFloors(arrayOfFloors):
	print("SETTING FLOORS")
	floors = arrayOfFloors

func setID(id):
	ID = id
		
		
	
	

	
