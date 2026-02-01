extends Resource
class_name Rumor

@export var id: String
@export var related_rule: MaskEffectRule

@export var min_bribe: int = 0
@export var risk_level: float = 0.0 # 0 = safe, 1 = dangerous

@export var true_variants: Array[RumorVariant] = []
@export var false_variants: Array[RumorVariant] = []
@export var vague_variants: Array[RumorVariant] = []
