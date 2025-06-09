extends Control

@onready var mana_label = $MainTabs/PracticeTab/VBoxContainer/ManaLabel
@onready var production_label = $MainTabs/PracticeTab/VBoxContainer/ProductionLabel
@onready var spell_grid = $MainTabs/PracticeTab/VBoxContainer/ScrollContainer/SpellGrid
@onready var druid_tab = $MainTabs/DruidTab
@onready var tick_timer = $TickTimer
@onready var druid_popup = $DruidPopup
@onready var essence_label = $MainTabs/DruidTab/VboxContainer/ManaLabel
@onready var druid_mana_label = $MainTabs/DruidTab/VboxContainer/EssenceLabel

var current_mana: float = 50.0
var has_shown_druid_message := false
var dryads := 0
var earth_essence := 0.0
var dryad_button

var spells = {
	"wisp": {"count": 10, "produces": "mana", "base_rate": 1.0, "rate_multiplier": 1.0, "level": 0, "casts": 9, "base_cost": 10, "current_cost": 35, "cap": -1},
	"wyrm": {"count": 0, "produces": "wisp", "base_rate": 0.5, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 100, "current_cost": 100, "cap": 1},
	"sprite": {"count": 0, "produces": "wyrm", "base_rate": 0.3, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 500, "current_cost": 500, "cap": 1},
	"elemental": {"count": 0, "produces": "sprite", "base_rate": 0.2, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 1500, "current_cost": 1500, "cap": 1},
	"spirit": {"count": 0, "produces": "elemental", "base_rate": 0.15, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 5000, "current_cost": 5000, "cap": 1},
	"golem": {"count": 0, "produces": "spirit", "base_rate": 0.1, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 15000, "current_cost": 15000, "cap": 1},
	"avatar": {"count": 0, "produces": "golem", "base_rate": 0.07, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 50000, "current_cost": 50000, "cap": 1},
	"ancient": {"count": 0, "produces": "avatar", "base_rate": 0.05, "rate_multiplier": 1.0, "level": 0, "casts": 0, "base_cost": 150000, "current_cost": 150000, "cap": 1}
}

func _ready():
	tick_timer.wait_time = 1.0
	tick_timer.timeout.connect(_on_TickTimer_timeout)
	tick_timer.start()

	druid_tab.visible = false
	$MainTabs.set_tab_disabled(1, true)
	$MainTabs.set_tab_title(1, "")

	_setup_spell_buttons()
	_update_all()

func _setup_spell_buttons():
	spell_grid.get_children().map(func(c): c.queue_free())
	for spell_name in spells.keys():
		await get_tree().process_frame
		var btn_scene = preload("res://ui/SpellButton.tscn")
		var btn = btn_scene.instantiate()
		btn.spell_name = spell_name
		btn.main_script = self
		spell_grid.add_child(btn)

func _create_dryad_button():
	var btn_scene = preload("res://ui/DryadButton.tscn")
	dryad_button = btn_scene.instantiate()
	dryad_button.main_script = self
	dryad_button.pressed.connect(_on_DryadButton_pressed)
	$MainTabs/DruidTab/VBoxContainer.add_child(dryad_button)

func _on_TickTimer_timeout():
	_produce()
	_generate_mana()
	_generate_essence()
	_update_all()

func _produce():
	var tier_order = ["ancient", "avatar", "golem", "spirit", "elemental", "sprite", "wyrm"]
	for tier in tier_order:
		var s = spells[tier]
		var output = s["produces"]
		var base_output = max(0.0, s["count"] * s["base_rate"] * s["rate_multiplier"])
		var capped_output = min(base_output, float(s["cap"])) if s["cap"] > 0 else base_output

		if spells.has(output):
			spells[output]["count"] += capped_output

	if spells["wyrm"]["count"] >= 2 and not has_shown_druid_message:
		has_shown_druid_message = true
		_show_druid_message()
		_unlock_druid_tab()

func _generate_mana():
	var wisp = spells["wisp"]
	current_mana += wisp["count"] * wisp["base_rate"] * wisp["rate_multiplier"]

func _generate_essence():
	earth_essence += dryads * 1.0

func _on_DryadButton_pressed():
	if current_mana >= 10:
		current_mana -= 10
		dryads += 1
		_update_druid_labels()

func cast_spell(spell_id: String):
	if !spells.has(spell_id):
		return
	var s = spells[spell_id]
	if current_mana >= s["current_cost"]:
		current_mana -= s["current_cost"]
		s["count"] += 1
		s["casts"] += 1
		s["current_cost"] = int(s["base_cost"] * pow(1.15, s["casts"]))
		if s["casts"] % 10 == 0:
			s["level"] += 1
			s["rate_multiplier"] = pow(2, s["level"])
		_update_all()

func _update_all():
	_update_mana_label()
	_update_production_label()
	_update_druid_labels()
	for btn in get_tree().get_nodes_in_group("spell_buttons"):
		if btn.has_method("_update_display"):
			btn._update_display()

func _update_mana_label():
	mana_label.text = "Mana: " + str(int(current_mana))

func _update_production_label():
	var wisp = spells["wisp"]
	var mana_per_sec = wisp["count"] * wisp["base_rate"] * wisp["rate_multiplier"]
	production_label.text = "Mana/sec: " + str(snapped(mana_per_sec, 0.01))

func _update_druid_labels():
	druid_mana_label.text = "Mana: %d" % int(current_mana)
	essence_label.text = "Earth Essence: %.1f" % earth_essence
	if dryad_button:
		dryad_button.dryad_count = dryads
		dryad_button.update_display()

func _show_druid_message():
	druid_popup.dialog_text = "Your Wyrms have reached their current production limit. 🌿 A new path opens...\n\nYou've unlocked the *Druid* spell school.\nBegin your magical research to grow stronger!"
	druid_popup.popup_centered()

func _unlock_druid_tab():
	druid_tab.visible = true
	$MainTabs.set_tab_disabled(1, false)
	$MainTabs.set_tab_title(1, "Druid")
	_create_dryad_button()
