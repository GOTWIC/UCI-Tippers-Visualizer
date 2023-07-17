extends Camera3D


var min_zoom = 5
var max_zoom = 50
var zoom_factor = 2
var zoom_level = 40.0
var zoomPercentage
var pan_speed = 0.0015

var orthSet = [1.0,30.0,2.0]
var perspSet = [5.0,50.0,3.5]

func set_zoom_level(value: float) -> void:
	zoom_level = clamp(value, min_zoom, max_zoom)
	if(self.projection == 0):
		self.fov = zoom_level
	elif(self.projection == 1):
		self.size = zoom_level

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		set_zoom_level(zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + zoom_factor)
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position += Vector3(event.relative[0] * zoom_level * pan_speed, 0, event.relative[1] * zoom_level * pan_speed)
	if event.is_action_pressed("change_perspective"):
		if(self.projection == 0):
			zoom_level = zoom_level/(perspSet[1] - perspSet[0]) * (orthSet[1] - orthSet[0])
			self.set_orthogonal(zoom_level, 0.05, 4000)
		elif(self.projection == 1):
			zoom_level = zoom_level/(orthSet[1] - orthSet[0]) * (perspSet[1] - perspSet[0])
			self.set_perspective(zoom_level, 0.05, 4000)
	

func _get_state():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(self.projection == 0):
		min_zoom = perspSet[0]
		max_zoom = perspSet[1]
		zoom_factor = perspSet[2]
	elif(self.projection == 1):
		min_zoom = orthSet[0]
		max_zoom = orthSet[1]
		zoom_factor = orthSet[2]
		
	zoomPercentage = (zoom_level - min_zoom) / (max_zoom - min_zoom)

func getZoomPercentage():
	return zoomPercentage
