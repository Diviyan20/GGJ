extends Area2D

@export var masks_for_sale: Array[MaskData]
@export var prices: Dictionary[String, int] = {}

var player_in_range: Node = null

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.has_method("equip_mask"):
		player_in_range = body

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null

func _input(event):
	if event.is_action_pressed("interact") and player_in_range:
		open_shop(player_in_range)

func open_shop(player):
	var available_masks = get_available_masks(player)

	if available_masks.is_empty():
		print("Merchant: You already have all my masks!")
		return

	# TEMP: buy first available mask
	var mask = available_masks[0]
	var price = prices.get(mask.mask_name, 0)

	if player.spend_money(price):
		player.equip_mask(mask)
		print("Bought:", mask.mask_name)
	else:
		print("Not enough money!")

func get_available_masks(player) -> Array:
	var result: Array = []

	for mask in masks_for_sale:
		if player.current_mask == null:
			result.append(mask)
		elif mask.mask_name != player.current_mask.mask_name:
			result.append(mask)
	return result
