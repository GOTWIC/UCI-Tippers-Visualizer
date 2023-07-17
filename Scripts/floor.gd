extends CSGPolygon3D

var minTransparency = 0.0
var maxTransparency = 0.8
var zoomVisibilityThreshold = 0.3

var originalColor

var zoom_percentage

var contextSwitchThreshold = 0.3

var hovering : bool = false

var occupancy = 0
var occupancyText

func _ready():
	originalColor = self.material.albedo_color
	var collider = get_node("Area3D").get_node("collision")
	collider.polygon = PackedVector2Array([Vector2(0, 0), Vector2(1, 2), Vector2(-1, 3), Vector2(-3, 1)])
	collider.depth = self.depth
	collider.position[2] -= self.depth/2
	
	get_node("Area3D").mouse_entered.connect(self.mouseEnter)
	get_node("Area3D").mouse_exited.connect(self.mouseExit)
	
	occupancyText = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer").get_node("OccupancyDisplay")
	fetchOccupancy()

func _process(delta):
	hoverActions()
	zoom_percentage = get_tree().get_root().get_node("Root").get_node("MapView").get_node("Camera").getZoomPercentage()
	var scaled_zoom_percentage = 1 - (min((1/zoomVisibilityThreshold) * zoom_percentage, 1))
	# Scale transparency to min/max transparency window
	var objTransparency = minTransparency + (maxTransparency - minTransparency) * scaled_zoom_percentage
	self.material.albedo_color[3] = objTransparency
	
func mouseEnter():
	hovering = true
	
func mouseExit():
	hovering = false
	occupancyText.text = "Occupancy: " 
	
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
	var rng = RandomNumberGenerator.new()
	occupancy = int(rng.randf_range(0, 100))
	
func getOccupancy():
	return occupancy
		
