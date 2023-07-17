extends Node

signal check_end

var counter = []

func _ready() -> void:
	print("ready")
	first()
	print("ready end")
	
func first() -> void:
	print("first")
	var iters = 100

	var http1 = HTTPRequest.new()
	var http2 = HTTPRequest.new()
	var http3 = HTTPRequest.new()
	var http4 = HTTPRequest.new()
	add_child(http1)
	add_child(http2)
	add_child(http3)
	add_child(http4)

	http1.use_threads = true
	http2.use_threads = true
	http3.use_threads = true
	http4.use_threads = true

	mid(http1, iters/4)
	mid(http2, iters/4)
	mid(http3, iters/4)
	mid(http4, iters/4)

	print("first end")

func mid(http, iters):
	for i in range(iters):
		var res = await dImg(http)
	print("mid end")

	
func _process(delta: float) -> void:
	emit_signal("check_end")
		
func dImg(http):
	var _error1 = http.request("https://tile.openstreetmap.org/19/90535/210049.png")
	var request_completed_info = await http.request_completed
	var result:int = request_completed_info[0];
	var response_code:int = request_completed_info[1];
	var body:PackedByteArray = request_completed_info[3];

	if result != 0:
		print("ERROR! UNABLE TO DOWNLOAD IMAGE. Result Code: " + str(result))
		# Add verbosity from https://docs.godotengine.org/en/stable/classes/class_httprequest.html
		return null
			
	var image = Image.new()
	var _error2 = image.load_png_from_buffer(body)
	var texture = ImageTexture.create_from_image(image)
	
	return texture

	
	
	
	
	
	

func second() -> void:
	print("second")
	var test_ret = await third()
	print("second end ", test_ret)

func third() -> int:
	print("third")
	await self.check_end
	print("third mid")
	await self.check_end
	print("third end")
	return 23

