extends Node

signal event(name, data)

func eval(js_code:String):
	if OS.has_feature("JavaScript"):
		return JavaScript.eval(js_code)
	else:
		return null

func call_function(func_name:String, params_array:Array = []):
	var params_str := params_array_to_str(params_array)
	var func_str = str(func_name, "(", params_str, ");")
	return JS_API.eval(func_str)
	
func params_array_to_str(params_array:Array) -> String:
	var params_str := ""
	var params_count := params_array.size()
	
	for i in range(params_count-1):
		var p = params_array[i]
		params_str += "'" + p + "'" + ", "
		
	if params_count > 0:
		params_str += "'" + params_array[params_count-1] + "'"
	
	return params_str
	
func new_event(eName:String, eData:String) -> void:
	JS_API.call_function("godotEvents.newEvent", [eName, eData])

# TODO - it shouldn't be in this script
func _ready():
	JS_API.new_event('ready', '')

# TODO - it shouldn't be in this script
func _process(delta):
	if JS_API.call_function("reactEvents.hasEvent"):
		while JS_API.call_function("reactEvents.hasEvent"):
			var event_name = JS_API.call_function("reactEvents.getCurrentEventName")
			var event_data = JS_API.call_function("reactEvents.getCurrentEventData")
			
			emit_signal("event", event_name, event_data)
			
			JS_API.call_function("reactEvents.next")
			
		JS_API.call_function("reactEvents.clearEventsArray")
