extends MenuButton

var aggregations = ["Count", "Max", "Min", "Mean", "Median"]

func _ready():
	for aggregation in aggregations:
		get_popup().add_item(aggregation)

func _process(delta):
	pass
