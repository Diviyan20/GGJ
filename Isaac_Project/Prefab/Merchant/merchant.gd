extends Area2D

@export var masks_for_sale: Array[MaskData]
@export var prices: Dictionary[String, int] = {}
@export var potions_for_sale: Array[PotionData]
@export var potion_prices: Dictionary[String, int] = {}
@export var shop_ui: NodePath

@export var merchant_profile: MerchantProfile
@export var rumors: Array[MaskEffectRule] = [] # .tres files go here
@export var greed_factor: float = 1.0 # how corrupt this merchant is

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

# -------------------
# BRIBERY SYSTEM
# -------------------
func offer_bribe(amount: int, player_money: int) -> Dictionary:
	if rumors.is_empty():
		return {
			"text": "I have nothing to say.",
			"success": false
		}
	
	# Find affordable rumor
	var selected_rumor = _select_rumor_by_bribe(amount)
	
	if selected_rumor == null:
		return {
			"text": "The merchant shrugs.",
			"success": false
		}
	
	# Calculate truth chance
	var truth_chance = _calculate_truth_chance(selected_rumor, amount, player_money)
	
	# Roll for outcome
	var roll = randf()
	var result: Dictionary
	
	if roll <= truth_chance:
		# Give truth
		result = _get_variant(selected_rumor.true_variants, true)
		result["outcome_type"] = "truth"
	elif roll <= truth_chance + 0.3:
		# Give vague answer
		result = _get_variant(selected_rumor.vague_variants, false)
		result["outcome_type"] = "vague"
	else:
		# Give lie
		result = _get_variant(selected_rumor.false_variants, false)
		result["outcome_type"] = "lie"
	
	result["success"] = true
	
	return result

func _select_rumor_by_bribe(amount: int) -> MaskEffectRule:  # Changed return type
	var affordable = []
	
	for rumor in rumors:
		if amount >= rumor.min_bribe:
			affordable.append(rumor)
	
	if affordable.is_empty():
		return null
	
	affordable.sort_custom(func(a, b): return a.min_bribe > b.min_bribe)
	
	return affordable[0]

func _calculate_truth_chance(rumor: MaskEffectRule, bribe_amount: int, player_money: int) -> float:  # Changed parameter type
	var effective_bribe = float(bribe_amount) / greed_factor
	
	# Normalize bribe
	var normalized = clamp(float(bribe_amount - rumor.min_bribe) / max(rumor.min_bribe, 1.0), 0.0, 1.0)
	
	# Base truth chance from bribe effectiveness
	var truth_chance = 0.2 + (normalized * 0.6)  # 20% to 80% range
	
	# Apply risk penalty
	truth_chance *= (1.0 - rumor.risk_level * 0.3)
	
	# Wealth sacrifice bonus
	var wealth_ratio = float(bribe_amount) / max(float(player_money), 1.0)
	if wealth_ratio > 0.5:
		truth_chance += 0.15
	
	return clamp(truth_chance, 0.0, 0.95)

func _get_variant(variants: Array[RumorVariant], is_true: bool) -> Dictionary:
	if variants.is_empty():
		return {
			"text": "...",
			"is_true": is_true,
			"confidence": 0.0
		}
	
	var chosen: RumorVariant = variants.pick_random()
	
	return {
		"text": chosen.text,
		"is_true": is_true,
		"confidence": chosen.confidence
	}

func _get_cheapest_rumor_price() -> int:
	if rumors.is_empty():
		return 0
	
	var min_price = rumors[0].min_bribe
	for rumor in rumors:
		if rumor.min_bribe < min_price:
			min_price = rumor.min_bribe
	
	return min_price
