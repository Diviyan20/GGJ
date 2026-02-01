extends Resource
class_name Rumor

@export var id: String
@export var truth_text: String
@export var lie_texts: Array[String]
@export var related_rule: MaskEffectRule

@export var min_bribe: int = 0
@export var risk_level: float = 0.0 # 0 = safe, 1 = dangerous
@export var base_truth_chance := 0.2
@export var max_truth_chance := 0.95
@export var bribe_soft_cap := 100

@export var true_variants: Array[RumorVariant] = []
@export var false_variants: Array[RumorVariant] = []
@export var vague_variants: Array[RumorVariant] = []
