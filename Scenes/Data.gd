extends Node

var data
var psql
var binned
var _timer

var updateInterval = 0.1

func _ready():
	data = {}
	binned = {'b': [], 'f': [], 'r': [], 'm': []}
	psql = get_tree().get_root().get_node("Root").get_node("PostgreSQL")
	updateData()
	startTimer()

func startTimer():
	_timer = Timer.new()
	add_child(_timer)

	_timer.timeout.connect(self._on_Timer_timeout)
	_timer.set_wait_time(60 * updateInterval)
	_timer.set_one_shot(false)
	_timer.start()
	
func _on_Timer_timeout():
	updateData()
	
	
func updateData():
	var space_metadata = await psql.query("space")
	var space_data_raw = await psql.query("sampleoccupancy")
	var space_data = {}
	
	# Upload occupancy data in searchable format
	for space in space_data_raw:
		space_data[space['space_id']] = {'occupancy': space['occupancy'], 'time': space['time']}
	
	for metadata in space_metadata:
		var sid = metadata['space_id'] 
		var tid = metadata['space_type_id']
		var pid = metadata['parent_space_id']
		var occ = 0
		if tid == 3:
			occ = space_data[sid]['occupancy']
		
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
				"location": metadata['vertices'],
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

		
