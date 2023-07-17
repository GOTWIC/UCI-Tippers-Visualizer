extends MenuButton

var floors = ["Basement", "Garage", "Floor 1", "Floor 2", "Floor 3", "Floor 4", "Floor 5", "Floor 6", "Floor 7", "Floor 8"]

func _ready():
	for floor in floors:
		get_popup().add_item(floor)

func _process(delta):
	pass
