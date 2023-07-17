extends MenuButton

var rooms = ["1001", "1002", "1003", "1004", "1005", "2023", "2024", "2026", "2027", "3377", "3378", "3379", "3380"]

func _ready():
	for room in rooms:
		get_popup().add_item(room)

func _process(delta):
	pass
