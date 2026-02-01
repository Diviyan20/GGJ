extends Control

@onready var mask_list = $MarginContainer/HBoxContainer/Panel/MaskList
@onready var potion_list = $MarginContainer/HBoxContainer/Panel/PotionList
@onready var close_button = $MarginContainer/HBoxContainer/Panel/CloseButton
@onready var bribe_button = $MarginContainer/HBoxContainer/BriberyPanel/MarginContainer/VBoxContainer/BribeButton

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
	var bribe_line_edit = $MarginContainer/HBoxContainer/BriberyPanel/MarginContainer/VBoxContainer/LineEdit
	var rumor_text = $MarginContainer/HBoxContainer/BriberyPanel/MarginContainer/VBoxContainer/RumorText

	if bribe_line_edit.text.strip_edges() == "":
		rumor_text.text = "The merchant stares at you, waiting."
		return

	var amount := int(bribe_line_edit.text)

	if amount <= 0:
		rumor_text.text = "You think this counts as a bribe?"
		return

	if not player.spend_money(amount):
		rumor_text.text = "Come back when you can afford secrets."
		return

	var result= merchant.offer_bribe(amount)

	if result.is_empty():
		rumor_text.text = "The merchant shrugs."
		return

	rumor_text.text = result["text"]
	bribe_line_edit.text = ""
