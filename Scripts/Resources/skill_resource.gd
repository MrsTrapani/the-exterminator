extends Resource
class_name SkillResource

enum SkillEffect { DAMAGE, DAMAGE_OVER_TIME, RESET_COOLDOWNS, DASH, DAMAGE_BUFF }

@export var skill_name: String
@export var skill_icon: Texture2D
@export var skill_description: String
@export var skill_damage: float = 0.0
@export var skill_cooldown: float

@export var skill_range: GameDictionary.AtkRange
@export var cast_time: GameDictionary.CastTime

@export var skill_effect: SkillEffect = SkillEffect.DAMAGE
@export var effect_duration: float = 0.0
@export var tick_interval: float = 1.0
@export var damage_multiplier: float = 1.0
@export var dash_distance: float = 0.0
