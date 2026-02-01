extends Node
class_name BriberySystem

var merchant_profile: MerchantProfile
var rumors: Array[Rumor]

func setup(profile: MerchantProfile, rumor_list: Array[Rumor]) -> void:
	merchant_profile = profile
	rumors = rumor_list

func attempt_bribe(
	rumor: Rumor,
	bribe_amount: int
) -> RumorVariant:

	var truth_chance := merchant_profile.base_honesty + (float(bribe_amount) / rumor.min_bribe) * merchant_profile.greed- (rumor.risk_level * merchant_profile.fear)

	truth_chance = clamp(truth_chance, 0.0, 1.0)
	var roll := randf()

	if roll < truth_chance:
		return rumor.true_variants.pick_random()
	elif roll < truth_chance + 0.25:
		return rumor.vague_variants.pick_random()
	else:
		return rumor.false_variants.pick_random()
