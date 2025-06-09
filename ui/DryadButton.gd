extends Button

var main_script
var dryad_count := 0

@onready var count_label = $VBoxContainer/CountLabel

func _ready():
	text = ""  # Remove default button text
	update_display()

func update_display():
	count_label.text = "Dryads: %d" % dryad_count
