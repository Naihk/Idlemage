extends Label

func _ready():
	set_process(true)
	text = "🧠 PerfOverlay"
	add_theme_color_override("font_color", Color.LIGHT_GREEN)
	add_theme_font_size_override("font_size", 14)
	set_position(Vector2(10, 10))
	z_index = 128  # max safe value in Godot 4.x

func _process(_delta):
	var tree = get_tree()
	var nodes = tree.get_node_count()
	var fps = Engine.get_frames_per_second()
	var mem = Performance.get_monitor(Performance.MEMORY_STATIC)
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)

	text = "🐍 NODES: %d\n⚡ FPS: %d\n🕒 Frame: %.2f ms\n💾 Mem: %.2f MB" % [
		nodes,
		fps,
		frame_time * 1000.0,
		mem / (1024.0 * 1024.0)
	]
