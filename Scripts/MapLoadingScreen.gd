extends Node2D

var progress
var mapRenderer
var progressBar
var progressText
var progressPercentage

var status

var screenClear = false

func _ready():
	mapRenderer = get_tree().get_root().get_node("Root").get_node("MapView").get_node("MapRenderer")
	progressBar = get_node("ProgressBar")
	progressText = get_node("ProgressText")
	progressPercentage = get_node("ProgressPercentage")
	status = get_node("Status")

func _process(delta):
	var progressData = mapRenderer.getMapLoadProgess()
	progress = float(progressData[0])/progressData[1] * 100
	
	if progressData[0] != progressData[1]:
		var progressTextStr = str(progressData[0]) + "/" + str(progressData[1])
		progressBar.value = progress
		progressText.text = progressTextStr
		progressPercentage.text = str(int(progress)) + "%"
	elif !screenClear:
		var progressTextStr = str(progressData[0]) + "/" + str(progressData[1])
		progressBar.value = progress
		progressText.text = progressTextStr
		progressPercentage.text = str(int(progress)) + "%"
		clearScreen()
		screenClear = true
		
		
func clearScreen():
	status.text = "Done!"
	await get_tree().create_timer(1.5).timeout
	self.hide()

	
		
	
	
	
