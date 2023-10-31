extends Node

var data
var psql
var binned
var _timer

var dataSriram
var stats
var timestamps_raw
var timestamps

var updateInterval = 2

func _ready():
	data = {}
	dataSriram = {}
	stats = {"min": 100000000, "max": 0}
	timestamps_raw = {}
	binned = {'b': [], 'f': [], 'r': [], 'm': []}
	psql = get_tree().get_root().get_node("Root").get_node("PostgreSQL")
	updateSData()
	#startTimer()

func startTimer():
	_timer = Timer.new()
	add_child(_timer)

	_timer.timeout.connect(self._on_Timer_timeout)
	_timer.set_wait_time(updateInterval)
	_timer.set_one_shot(false)
	_timer.start()
	
func _on_Timer_timeout():
	updateSData()
	
	
func updateData():
	var space_metadata = await psql.query("space")
	var space_data_raw = await psql.query("sampleoccupancy")
	var space_data = {}
	
	# Upload occupancy data in searchable format
	for space in space_data_raw:
		space_data[space['space_id']] = {'occupancy': space['occupancy'], 'time': space['time']}
	
	for metadata in space_metadata:
		
		var loc = metadata['vertices']
		var sid = metadata['space_id'] 
		var tid = metadata['space_type_id']
		var pid = metadata['parent_space_id']
		var occ = 0
			
		if tid == 3:
			occ = space_data[sid]['occupancy']	
			if loc == null:
				continue
		
		# Update
		if sid in data:
			if tid == 3:
				data[sid]['occupancy'] = occ
			# Keep outdated floor + building occupancies
			# instead of setting back to 0 for a fraction of a second
		
		# Create
		else:
			# Add to data
			data[sid] = {
				"name": metadata['space_name'],
				"location": loc,
				"occupancy": occ,
				"parent_id": pid,
				"space_type_id": tid,
				"children": [],
			}
			
			# Add to binned
			var bin = assignBin(tid)
			binned[bin].append(sid)		
			
			if pid and pid not in data:
				# Parent ID assigned but does not exist
				print("PARENT FOR SPACE ID: " + str(sid) + " DOES NOT EXISTS")
			if pid and pid in data:
				# Update parent
				data[pid]['children'].append(sid)
			else:
				# No parent
				pass

		
	# Update occupancy of floors and buildings 
	# Start from smallest to largest layer, 
	# since occupancy of parents is dependent on child
	
	updateParentOccupancy('f')
	updateParentOccupancy('b')
	parsePositions()
	sortFloors()
	
	return true
		
func assignBin(tid):
	if tid == 1:
		return 'b'
	elif tid == 2:
		return 'f'
	elif tid == 3:
		return 'r'
	else:
		#print("INVALID SPACE TYPE FOUND (" + str(tid) + ") - DUMPING IN MISC")
		return 'm'
		
func updateParentOccupancy(bin):
	for pID in binned[bin]:
		var occ = 0
		for cID in data[pID]['children']:
			occ += data[cID]['occupancy']
		data[pID]['occupancy'] = occ
		
func getData():
	return data
	
func getBinned():
	return binned

func sortFloors():
	for b in binned['b']:
		data[b]['children'].sort_custom(sortFunc)
		
func sortFunc(a,b):
	return data[a ]['name'] < data[b]['name']

func parsePositions():
	for r in binned['r']:
		if(typeof(data[r]['location'][0]) != 27):
			continue
		var loc = []
		for coord in data[r]['location']:
			loc.append(Vector2(float(coord['lat']), float(coord['lng'])))
		if len(loc) == 2:
			# Rectangle
			var x1 = loc[0][0]
			var y1 = loc[0][1]
			var x2 = loc[1][0]
			var y2 = loc[1][1]
			loc = [Vector2(x1,y1),Vector2(x1,y2),Vector2(x2,y2),Vector2(x2,y1)]
			
		data[r]['location'] = loc
		
func updateSData():
	
	var contamination_data = await psql.query("pollutant_concentration")
	for row in contamination_data:
		var row_ts = dt_to_epk(row['timestamp'])
		var row_coords_raw = row['coordinates']
		var row_coords = deRect(row_coords_raw)
		var row_plt = row['pollutant']
		var row_con = row['concentration']
		
		stats['min'] = [stats['min'], row_con].min()
		stats['max'] = [stats['max'], row_con].max()
		
		# Add timestamp/concentration
		if row_coords not in dataSriram:
			dataSriram[row_coords_raw] = {
				"location": row_coords,
				"instances": {}
			}
			
		dataSriram[row_coords_raw]["instances"][row_ts] = [row_con, row_plt]
		timestamps_raw[row_ts] = 0
		
	timestamps = timestamps_raw.keys()
	timestamps.sort()	
	return
	
			
func dt_to_epk(datetime):
	var epoch = Time.get_unix_time_from_datetime_string(datetime)
	return epoch
	
func sgetData():
	return dataSriram

# de-Rectangle location parameters -
# turns two corner points into a set of four points that define a rectangle
func deRect(two_pt_coords):
	var coords_list = two_pt_coords
	var unwanted_chars = [":","?","(",")"," "]

	for c in unwanted_chars:
		coords_list = coords_list.replace(c,"")
	
	coords_list = coords_list.split(",")
	
	var x1 = float(coords_list[0])
	var y1 = float(coords_list[1])
	var x2 = float(coords_list[2])
	var y2 = float(coords_list[3])
	
	return [
		{'lat': x1, 'lng': y1},
		{'lat': x1, 'lng': y2},
		{'lat': x2, 'lng': y2},
		{'lat': x2, 'lng': y1}
	]
	
func sgetStats():
	return stats
	
func sgetTimestamps():
	return timestamps
	
	
	

	
