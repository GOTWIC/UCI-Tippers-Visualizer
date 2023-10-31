extends Node2D

var btn

var MapViewNode = preload("res://Subscenes/MapRenderer.tscn")
var GraphViewNode = preload("res://Subscenes/GraphScene.tscn")
var ListViewNode = preload("res://Subscenes/ListScene.tscn")
var Vcontainer

var views = []

var num_rows_prev = 0

var canvas_h
var canvas_w

func _ready():
	canvas_w = ProjectSettings.get_setting("display/window/size/viewport_width")
	canvas_h = 0.8 * ProjectSettings.get_setting("display/window/size/viewport_height")
	
	print(canvas_h)
	
	btn = get_node("MenuButton")
	btn.get_popup().id_pressed.connect(addView)
	
	btn.get_popup().add_item("Map")
	btn.get_popup().add_item("Graph")
	btn.get_popup().add_item("List")
	
	#container = HBoxContainer.new()
	Vcontainer = VBoxContainer.new()
	Vcontainer.size = Vector2(canvas_w,canvas_h)
	Vcontainer.alignment = BoxContainer.ALIGNMENT_CENTER
	
	get_node("Control").add_child(Vcontainer)
	
	print(ProjectSettings.get_setting("display/window/size/viewport_height"))
	
	
func _process(delta):
	pass
		

func addView(id):
	
	var svpc = addViewport(id)	
	svpc.name = str(len(views)+1)
	views.append(svpc)
	var num_rows_new = int((len(views)**0.5)+1)
	
	if is_square(len(views)):
		num_rows_new = int(len(views)**0.5)
	
	var view_size_multi = 1/float(num_rows_new)
	var new_size = canvas_h * view_size_multi
	svpc.get_node("svp").size = Vector2(new_size * 16/9, new_size)
	if id != 0:
		svpc.get_node("svp").get_children()[0].scale = Vector2(view_size_multi * 0.8, view_size_multi * 0.8)

	
	#print("new: " + str(num_rows_new) + " prev: " + str(num_rows_prev))
	
	if num_rows_new == num_rows_prev:
		var row_to_add = 0
		var num_child_in_row_to_add = 100000000
		for i in range(num_rows_new):
			if len(Vcontainer.get_children()[i].get_children()) <= num_child_in_row_to_add:
				row_to_add = i
				num_child_in_row_to_add = len(Vcontainer.get_children()[i].get_children())
		print(row_to_add)
		Vcontainer.get_children()[row_to_add].add_child(svpc)
			
	else:
		var hcont = HBoxContainer.new()
		hcont.alignment = BoxContainer.ALIGNMENT_CENTER
		hcont.SIZE_SHRINK_CENTER
		Vcontainer.add_child(hcont)
		
		#resize existing containers
		for view in views:
			view.get_node("svp").size = Vector2(new_size * 16/9, new_size)
			if svpc.get_node("svp").get_children()[0].name != "0":
				view.get_node("svp").get_children()[0].scale = Vector2(view_size_multi * 0.8, view_size_multi * 0.8)
		hcont.add_child(svpc)
	
	num_rows_prev = num_rows_new
		
	
func addViewport(id):
	var svpc = SubViewportContainer.new()
	var svp = SubViewport.new()
	#var contents = ColorRect.new()
	var contents
	var vpSize = Vector2(canvas_h * 16/9,canvas_h)
	svp.size = vpSize
	
	if id == 0:
		contents =  MapViewNode.instantiate()
		#contents.color = Color(1,0,0)
	elif id == 1:
		contents =  GraphViewNode.instantiate()
		#contents.color = Color(0,1,0)
	elif id == 2:
		contents =  ListViewNode.instantiate()
		#contents.color = Color(0,0,1)
		
	svp.name = "svp"
	contents.name = str(id)
	
	var label = Label.new()
	label.text = str(len(views) + 1)
	#label.add_color_override("font_color", Color(0,0,0))
	
	label.add_theme_font_size_override("font_size", 50)
	contents.add_child(label)
	svp.add_child(contents)
	svpc.add_child(svp)
	return svpc
	
	
	

	
	
static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
	
func is_square(n):
	return float(n**0.5) == int(n**0.5)
	
	
