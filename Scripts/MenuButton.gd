extends MenuButton

var MapView
var GraphView
var ListView


func _ready():	
	get_popup().id_pressed.connect(navigateMenu)
	
	get_popup().add_item("Map")
	get_popup().add_item("Graph")
	get_popup().add_item("List")
	
	MapView = get_tree().get_root().get_node("Root").get_node("MapView")
	GraphView = get_tree().get_root().get_node("Root").get_node("GraphView")
	ListView = get_tree().get_root().get_node("Root").get_node("ListView")
	
	mapView()

func _process(delta):
	pass
	
func navigateMenu(id):
	if id == 0:
		mapView()
	elif id == 1:
		graphView()
	elif id == 2:
		listView()
	
func mapView():
	MapView.visible = true
	GraphView.visible = false
	ListView.visible = false
	
func graphView():
	MapView.hide()
	GraphView.show()
	ListView.hide()
	
func listView():
	MapView.visible = true
	GraphView.visible = false
	ListView.visible = true
	
	
