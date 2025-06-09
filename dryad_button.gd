extends Button

var main_script
var dryad_count := 0

@onready var title_label = $VBoxContainer/TitleLabel
@onready var cost_label = $VBoxContainer/CostLabel
@onready var count_label = $VBoxContainer/CountLabel

func _ready():
	text = ""  # Remove default text, we use custom layout
	update_display()

func update_display():
	count_label.text = "Dryads: %d" % dryad_count
