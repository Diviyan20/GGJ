extends Area2D

@export var masks_for_sale: Array[MaskData]
@export var prices: Dictionary[String, int] = {}
@export var potions_for_sale: Array[PotionData]
@export var potion_prices: Dictionary[String, int] = {}
@export var shop_ui: NodePath

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
	var ui = get_node(shop_ui)
	ui.open(self, player)
	print("Opening shop UI:", get_node(shop_ui))

#func get_available_masks(player) -> Array:
	#var result: Array = []
#
	#for mask in masks_for_sale:
		#if player.current_mask == null:
			#result.append(mask)
		#elif mask.mask_name != player.current_mask.mask_name:
			#result.append(mask)
	#return result
