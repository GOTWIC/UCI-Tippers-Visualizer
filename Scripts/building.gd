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


func _ready():
	originalColor = self.material.albedo_color
	var collider = get_node("Area3D").get_node("collision")
	collider.polygon = PackedVector2Array([Vector2(0, 0), Vector2(1, 2), Vector2(-1, 3), Vector2(-3, 1)])
	collider.depth = self.depth
	collider.position[2] -= self.depth/2
	
	get_node("Area3D").mouse_entered.connect(self.mouseEnter)
	get_node("Area3D").mouse_exited.connect(self.mouseExit)
	
	occupancyText = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer").get_node("OccupancyDisplay")


func _process(delta):
	calculateOccupancy()
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
		
func calculateOccupancy():
	occupancy = 0
	for floor in floors:
		occupancy += floor.get_node("Polygon").getOccupancy()
	
func setFloors(arrayOfFloors):
	print("SETTING FLOORS")
	floors = arrayOfFloors


		
		
	
	

	
