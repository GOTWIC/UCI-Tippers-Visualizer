extends Node3D

var MapRenderer = preload("res://Subscenes/MapRenderer.tscn")
var GraphView = preload("res://Subscenes/GraphScene.tscn")
var ListView = preload("res://Subscenes/ListScene.tscn")

var MapLoadingScene = preload("res://Subscenes/MapLoadingScene.tscn")

var canvas = preload("res://Scenes/Canvas.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mapRendererInst = MapRenderer.instantiate()
	var graphViewInst = GraphView.instantiate()
	var listViewInst = ListView.instantiate()
	
	var mapLoadingSceneInst = MapLoadingScene.instantiate()
	
	get_node("MapView").add_child(mapRendererInst)
	get_node("GraphView").add_child(graphViewInst)
	get_node("ListView").add_child(listViewInst)
	
	#get_node("MapView").add_child(mapLoadingSceneInst)
	
	var canvasInst = canvas.instantiate()
	#add_child(canvasInst)

func _process(_delta):
	pass
	

