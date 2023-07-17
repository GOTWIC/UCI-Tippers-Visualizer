extends MenuButton

var buildings = ["Aldrich Hall", "Berk Hall", "Beckman Laser Institute", "Croul Hall", "Donal Bren Hall", "Engineering Gateway", "Engineering Hall", "Faculty Research Facility", "Humanities Gateway", "Humanities Hall", "Irvine Hall", "Krieger Hall", "Medical Sciences A", "Rowland Hall", "Science Library", "UCI Medical Center"]

func _ready():
	for building in buildings:
		get_popup().add_item(building)

func _process(delta):
	pass
