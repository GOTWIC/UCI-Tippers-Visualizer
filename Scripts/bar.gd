extends CSGPolygon3D

var minTransparency = 0.2
var maxTransparency = 0.7

var zoom_percentage

var contextSwitchThreshold = 0.3

var hovering : bool = false

var concentration = 0
var occupancyText

var ID

var collider
var orig_collider_y

var dataObj
var timeSlider

var data
var stats
var timestamps

func _ready():
	collider = get_node("Area3D").get_node("collision")
	collider.polygon = self.polygon
	collider.depth = self.depth
	orig_collider_y = collider.position[2]
	collider.position[2] = orig_collider_y - self.depth/2
	
	get_node("Area3D").mouse_entered.connect(self.mouseEnter)
	get_node("Area3D").mouse_exited.connect(self.mouseExit)
	
	dataObj = get_tree().get_root().get_node("Root").get_node("Data")
	timeSlider = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer").get_node("TimeSlider")
	
	occupancyText = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer").get_node("PanelContainer").get_node("OccupancyDisplay")


func _process(delta):
	zoom_percentage = get_tree().get_root().get_node("Root").get_node("MapView").get_node("Camera").getZoomPercentage()
	hoverActions()
	fetchConcentration()
	changeBarHeightAndColor()
	
	# Scale transparency to min/max transparency window
	var objTransparency = minTransparency + (maxTransparency - minTransparency) * zoom_percentage
	self.material.albedo_color[3] = objTransparency

	

	
func mouseEnter():
	hovering = true
	
func mouseExit():
	hovering = false
	occupancyText.text = "Concentration: " + str(0) 
	
func hoverActions():
	get_node("Area3D").visible = true
	if hovering:
		occupancyText.text = "Concentration: " + str(concentration)

		
func fetchConcentration():
	data = dataObj.sgetData()
	stats = dataObj.sgetStats()
	timestamps = dataObj.sgetTimestamps()
	
	var currSliderTS = timestamps[timeSlider.value]
	
	if currSliderTS in data[ID]['instances'].keys():
		concentration = data[ID]['instances'][currSliderTS][0]
	
	else:
		concentration = -1
		

func changeBarHeightAndColor():
	if concentration != -1:
		self.visible = true
		self.depth = 2 * concentration
		var grad = (concentration-stats['min'])/(stats['max'] - stats['min'])
		self.material.albedo_color = Color(2 * grad,2 * (1-grad),0)
		collider.depth = self.depth
		collider.position[2] = orig_collider_y - self.depth/2
	else:
		self.visible = false

func setID(id):
	ID = id
		
		
	
	

	
