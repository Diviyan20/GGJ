extends Resource
class_name MaskEffectRule

@export var risk_level: float = 0.5
@export var min_bribe: int = 50

@export var true_variants: Array[RumorVariant]
@export var false_variants: Array[RumorVariant]
@export var vague_variants: Array[RumorVariant]
