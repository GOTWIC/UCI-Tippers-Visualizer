extends Node3D

var MapRenderer = preload("res://Subscenes/MapRenderer.tscn")
var GraphView = preload("res://Subscenes/GraphScene.tscn")
var ListView

var MapLoadingScene = preload("res://Subscenes/MapLoadingScene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mapRendererInst = MapRenderer.instantiate()
	var graphViewInst = GraphView.instantiate()
	
	var mapLoadingSceneInst = MapLoadingScene.instantiate()
	
	get_node("MapView").add_child(mapRendererInst)
	get_node("GraphView").add_child(graphViewInst)
	
	get_node("MapView").add_child(mapLoadingSceneInst)

func _process(_delta):
	pass
	

