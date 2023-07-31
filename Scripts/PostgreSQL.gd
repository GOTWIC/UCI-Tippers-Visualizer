extends Node

const POSTGREST_HOST = "steptippers-caredex.ics.uci.edu"

func get_base_url() -> String:
	return "https://%s/" % [POSTGREST_HOST]
	
func query(query):
	#printTime()
	var http = HTTPRequest.new()
	add_child(http)
	http.request(get_base_url() + query, [], HTTPClient.METHOD_GET)
	var result = await http.request_completed
	var response = _parse_http_response(result)
	http.queue_free()
	return response['body']
	#printTime()

func _parse_http_response(res):
	var body = PackedByteArray(res[3]).get_string_from_ascii()
	var regex = RegEx.new()
	regex.compile("([a-zA-Z\\-]+):\\s:?(.*)")
	
	var headers = {}
	var headers_list = res[2]
	for header in headers_list:
		var entries = header.split(":", true, 1)
		var key = entries[0].strip_edges()
		var value = entries[1].strip_edges()
		headers[key] = value
	
	body = text_to_object(body)
	
	return {
		"result": res[0],
		"response_code": res[1],
		"headers": headers,
		"body": body
	}
	
	
func object_to_text(obj):
	var json = JSON.new()
	return json.stringify(obj)


func text_to_object(text:String):
	var json = JSON.new()
	var error = json.parse(text)
	if error == OK:
		return json.get_data()
	else:
		return error
	pass


#func print(obj, indent = 0, sort_keys = {}):
#	print(object_to_text(obj))
	
	
func printTime():
	var time = Time.get_time_dict_from_system()
	print("%02d:%02d:%02d" % [time.hour, time.minute, time.second])
	
