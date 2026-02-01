extends Control

@onready var mask_list = $MarginContainer/HBoxContainer/Panel/MaskList
@onready var potion_list = $MarginContainer/HBoxContainer/Panel/PotionList
@onready var close_button = $MarginContainer/HBoxContainer/Panel/CloseButton

@onready var bribe_button = $MarginContainer/HBoxContainer/BriberyPanel/MarginContainer/VBoxContainer/BribeButton
@onready var bribe_line_edit = $MarginContainer/HBoxContainer/BriberyPanel/MarginContainer/VBoxContainer/LineEdit
@onready var rumor_text = $MarginContainer/HBoxContainer/BriberyPanel/MarginContainer/VBoxContainer/RumorText

var merchant
var player

func _ready():
	bribe_button.pressed.connect(_on_bribe_pressed)
	close_button.pressed.connect(close)
	visible = false

func open(m, p):
	merchant = m
	player = p
	visible = true
	refresh()
	populate_potions()
	
	# Set initial bribery text
	rumor_text.text = "Whisper me a secret... for the right price."

func refresh():
	for c in mask_list.get_children():
		c.queue_free()

	for mask in merchant.masks_for_sale:
		if player.owned_masks.has(mask):
			continue

		if not merchant.prices.has(mask.mask_name):
			continue

		var price = merchant.prices[mask.mask_name]
		var btn := Button.new()
		btn.text = "%s\n$%d" % [mask.mask_name, price]
		btn.icon = mask.icon
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(160, 64)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func():
			buy_mask(mask, price)
		)
		mask_list.add_child(btn)

func buy_mask(mask: MaskData, price: int):
	if not player.spend_money(price):
		print("Not enough money")
		return

	player.equip_mask(mask)
	refresh() # update UI after purchase

func populate_potions():
	for c in potion_list.get_children():
		c.queue_free()

	for potion in merchant.potions_for_sale:
		if not merchant.potion_prices.has(potion.potion_name):
			continue

		var price = merchant.potion_prices[potion.potion_name]

		var btn := Button.new()
		btn.text = "%s\n$%d" % [potion.potion_name, price]
		btn.icon = potion.icon
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(160, 64)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		btn.pressed.connect(func():
			buy_potion(potion, price)
		)

		potion_list.add_child(btn)

func buy_potion(potion: PotionData, price: int):
	if not player.spend_money(price):
		print("Not enough money")
		return

	player.apply_potion(potion)


func close():
	visible = false

func _on_bribe_pressed():
	if bribe_line_edit.text.strip_edges() == "":
		rumor_text.text = "The merchant stares at you, waiting."
		return
	
	var amount := int(bribe_line_edit.text)
	
	if amount <= 0:
		rumor_text.text = "You think this counts as a bribe?"
		return
	
	# Check affordability
	if amount > player.money:
		rumor_text.text = "You don't have that much. (You have %d coins)" % player.money
		return
	
	# Process the bribe
	var result = merchant.offer_bribe(amount, player.money)
	
	if not result.get("success", false):
		rumor_text.text = result.get("text", "The merchant shrugs.")
		return
	
	# Spend money
	if not player.spend_money(amount):
		rumor_text.text = "Something went wrong."
		return
	
	# Format the result text
	var display_text = result.get("text", "...")
	#var confidence = result.get("confidence", 0.0)
	
	# Add confidence indicator
	#if confidence >= 0.8:
		#display_text += "\n(The merchant speaks with certainty)"
	#elif confidence >= 0.5:
		#display_text += "\n(The merchant seems somewhat sure)"
	#elif confidence > 0.0:
		#display_text += "\n(The merchant looks uncertain)"
	
	rumor_text.text = display_text
	
	## Color code by outcome
	#match result.get("outcome_type", ""):
		#"truth":
			#rumor_text.add_theme_color_override("font_color", Color.GREEN)
		#"vague":
			#rumor_text.add_theme_color_override("font_color", Color.YELLOW)
		#"lie":
			#rumor_text.add_theme_color_override("font_color", Color.RED)
		#_:
			#rumor_text.remove_theme_color_override("font_color")
	
	bribe_line_edit.text = ""
