extends Area2D

@export var masks_for_sale: Array[MaskData]
@export var prices: Dictionary[String, int] = {}
@export var potions_for_sale: Array[PotionData]
@export var potion_prices: Dictionary[String, int] = {}
@export var shop_ui: NodePath


@export var merchant_profile: MerchantProfile
@export var rumors: Array[Rumor]
@export var greed_factor: float = 1.0 # how corrupt this merchant is


var player_in_range: Node = null
var bribery_system: BriberySystem

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

# -------------------
# BRIBERY SYSTEM
# -------------------
func offer_bribe(amount: int) -> Dictionary:
	# Pick a random rumor the merchant knows
	if rumors.is_empty():
		return {}

	var rumor: Rumor = rumors.pick_random()

	# Adjust bribe by merchant greed
	var effective_bribe := int(amount / greed_factor)

	# Calculate truth chance
	var truth_chance = clamp(
		float(effective_bribe - rumor.min_bribe) / float(rumor.min_bribe),
		0.0,
		1.0
	)

	# Risk makes lies more likely
	truth_chance *= (1.0 - rumor.risk_level)

	var roll := randf()

	if roll <= truth_chance:
		return _get_variant(rumor.true_variants, true)
	elif roll <= truth_chance + 0.3:
		return _get_variant(rumor.vague_variants, false)
	else:
		return _get_variant(rumor.false_variants, false)

func _get_variant(variants: Array[RumorVariant], is_true: bool) -> Dictionary:
	if variants.is_empty():
		return {}

	var chosen: RumorVariant = variants.pick_random()

	return {
		"text": chosen.text,
		"is_true": is_true,
		"confidence": chosen.confidence
	}
