extends Node3D

var tile = preload("res://Subscenes/tile.tscn")
var polygonPrefab = preload("res://Subscenes/Polygon.tscn")
var buildingMaterial = preload("res://materials/building.tres")
var floorMaterial = preload("res://materials/floor.tres")

var xDim
var yDim
var tileCoords = []

var tileSize = 5
var floorHeight = 0.2
var zoom_level = 17

var data
var binned

var tilesLoaded = 0
var built = []

var _timer

func _ready():
	await getData()
	setTileSize()
	await getTileCoords()
	mapCreationProcess()
	buildingCreationProcess()
	startTimer()
	
func getData():
	var dataObj = get_tree().get_root().get_node("Root").get_node("Data")
	var res = await dataObj.updateData()
	data = dataObj.getData()
	binned = dataObj.getBinned()
	
func setTileSize():
	if zoom_level == 17:
		tileSize = 5
	elif zoom_level == 18:
		tileSize = 3.5
	elif zoom_level == 19:
		tileSize = 2
	
func getTileCoords():
	var longlatcoords = []
	
	for building in binned['b']:
		for loc in data[building]['location']:
			var converted = deg2num(float(loc['lat']), float(loc['lng']))
			longlatcoords.append([converted[0], converted[1]])

	var result = getAllTileCoords(longlatcoords)
	tileCoords = result[0]
	xDim = result[1][0]		
	yDim = result[1][1]	
	
	return true	

func _process(_delta):
	pass

func startTimer():
	_timer = Timer.new()
	add_child(_timer)

	_timer.timeout.connect(self._on_Timer_timeout)
	_timer.set_wait_time(6)
	_timer.set_one_shot(false)
	_timer.start()
	
func _on_Timer_timeout():
	await getData()
	buildingCreationProcess()


func mapCreationProcess():

	var http1 = HTTPRequest.new()
	var http2 = HTTPRequest.new()
	var http3 = HTTPRequest.new()
	var http4 = HTTPRequest.new()

	get_node("HTTPReqs").add_child(http1)
	get_node("HTTPReqs").add_child(http2)
	get_node("HTTPReqs").add_child(http3)
	get_node("HTTPReqs").add_child(http4)

	var dlJobs = tileCoords.size() / 4

	downloadImgThread(http1, dlJobs, 0)
	downloadImgThread(http2, dlJobs, dlJobs)
	downloadImgThread(http3, dlJobs, dlJobs * 2)
	downloadImgThread(http4, tileCoords.size() - dlJobs * 3, dlJobs * 3)

func getAllTileCoords(lst2):
	var least_x = float(10000000)
	var greatest_x = float(-10000000)
	var least_y = float(10000000)
	var greatest_y = float(-10000000)
	var dimensions = []
	var totalCoordList = []
	
	for coordinate in lst2:
		var x = coordinate[0]
		var y = coordinate[1]

		# Check for the least and greatest x values
		if x < least_x:
			least_x = x
		if x > greatest_x:
			greatest_x = x

		# Check for the least and greatest y values
		if y < least_y:
			least_y = y
		if y > greatest_y:
			greatest_y = y

	dimensions = [greatest_x - least_x + 1, greatest_y - least_y + 1]
	
	for x in range(least_x, greatest_x + 1):
		for y in range(least_y, greatest_y + 1):
			totalCoordList.append([x, y])

	return [totalCoordList, dimensions]

func downloadImgThread(http, dlJobs, start):
	print("Assigning " + str(dlJobs) + " tasks to thread")
	var origin = Vector3((xDim - 1) * -0.5, 0, (yDim-1) * -0.5)
	for i in range(dlJobs):
		var texture = await downloadImage(http, tileCoords[i + start][0], tileCoords[i + start][1])	
		var rowNum = yDim - 1 - (start + i)%yDim
		var colNum = xDim - 1 - (start + i)/yDim
		var blank = tile.instantiate()
		var pixelSize = tileSize * 0.00390625 
		blank.get_node("tileSprite").set_pixel_size(pixelSize)
		blank.position = Vector3((colNum + origin.x) * tileSize, 0 , (rowNum + origin.z) * tileSize)
		blank.get_node("tileSprite").set_texture(texture)
		get_node('Tiles').add_child(blank)
		tilesLoaded += 1
		
	print("Thread Finished")

func downloadImage(http, xCoord, yCoord):
	var _error1 = http.request("https://tile.openstreetmap.org/" + str(zoom_level) + "/" + str(xCoord) + "/" + str(yCoord) + ".png")
	var request_completed_info = await http.request_completed
	var result:int = request_completed_info[0];
	var _response_code:int = request_completed_info[1];
	var body:PackedByteArray = request_completed_info[3];

	if result != 0:
		print("ERROR! UNABLE TO DOWNLOAD IMAGE. Result Code: " + str(result))
		# Add verbosity from https://docs.godotengine.org/en/stable/classes/class_httprequest.html
		return null
			
	var image = Image.new()
	var _error2 = image.load_png_from_buffer(body)
	var texture = ImageTexture.create_from_image(image)
	
	return texture




func buildingCreationProcess():
	var geo_origin = num2deg(tileCoords[yDim-1][0], tileCoords[yDim-1][1] + 1)
	var geo_end = num2deg(tileCoords[len(tileCoords)-yDim][0] + 1, tileCoords[len(tileCoords)-yDim][1])
		
	for building in binned['b']:
		if building in built:
			continue
		else:
			built.append(building)
			print("Else - Creating New Building")
		print("Process - Creating New Building")
		var points = getBuildingPoints(data[building]['location'], geo_origin, geo_end)
		var bID = building
		var fIDs = data[bID]['children'] 
		createBuilding(points, bID, fIDs)
		

func getBuildingPoints(locJson, g_o, g_e):
	
	var latlongVert = []
	var points = []

	var map_origin = Vector3((xDim - 1) * -0.5, 0, (yDim-1) * -0.5)
	var pixel_origin = [(xDim - 0.5 + map_origin.x) * tileSize, (map_origin.z - 0.5) * tileSize]
	var map_height = yDim * tileSize
	var map_width = xDim * tileSize
	
	for vert in locJson:
		latlongVert.append([map_height * ratiofy(vert['lat'],g_o[0], g_e[0]), map_width * ratiofy(vert['lng'],g_o[1], g_e[1])])
	
	for vert in latlongVert:
		points.append(Vector2(pixel_origin[0] - vert[1] , pixel_origin[1] + vert[0]))
	
	return points

func ratiofy(coord, o, e):
	return (float(coord) - o)/(e - o)
	

func createBuilding(points, bID, fIDs):
	var building = createPolygon(points, floorHeight * len(fIDs), true)
	var floors = []
	for i in range(len(fIDs)):
		var fID = fIDs[i]
		var floor = createPolygon(points, floorHeight/10, false, building)
		floor.name = data[fID]['name']
		floor.position[1] = i * floorHeight
		floor.get_node("Polygon").setID(fID)
		floors.append(floor)
	building.get_node("Polygon").setFloors(floors)
	building.get_node("Polygon").setID(bID)

func createPolygon(points : PackedVector2Array, height : float, isBuilding : bool, master = null):
	var polygonInst = polygonPrefab.instantiate()
	var poly = polygonInst.get_node("Polygon")
	if isBuilding:
		poly.set_script(load("res://Scripts/building.gd"))
		poly.material = buildingMaterial.duplicate()
	else:
		poly.set_script(load("res://Scripts/floor.gd"))
		poly.material = floorMaterial.duplicate()
	poly.polygon = points
	poly.depth = height
	if master:
		master.add_child(polygonInst)
	else:
		get_node('Buildings').add_child(polygonInst)
	return polygonInst
	
	
	
	
func getMapLoadProgess():
	return [tilesLoaded, xDim * yDim]
	
func deg2num(lat_deg, lon_deg):
	var lat_rad = deg2rad(lat_deg)
	var n = pow(2, zoom_level)
	var xtile = int((lon_deg + 180.0) / 360.0 * n)
	var ytile = int((1.0 - asinh(tan(lat_rad)) / PI) / 2.0 * n)
	return [xtile, ytile]

func num2deg(xtile, ytile):
	var n = pow(2, zoom_level)
	var lon_deg = xtile / n * 360.0 - 180.0
	var lat_rad = atan(sinh(PI * (1 - 2 * ytile / n)))
	var lat_deg = rad2deg(lat_rad)
	return [lat_deg, lon_deg]

func deg2rad(deg):
	return deg * PI / 180			

func rad2deg(rad):
	return rad * 180.0 / PI

func asinh(x: float) -> float:
	return log(x + sqrt(x * x + 1.0))
			
			
