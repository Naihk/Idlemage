extends Button

var spell_name: String = ""
var main_script

func _ready():
	text = ""  # We'll use custom labels/layout if needed
	self.pressed.connect(_on_pressed)
	add_to_group("spell_buttons")
	_update_display()

func _on_pressed():
	if main_script:
		main_script.cast_spell(spell_name)

func _update_display():
	self.text = spell_name.capitalize()
