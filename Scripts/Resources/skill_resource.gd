extends Resource
class_name SkillResource

@export var skill_name: String
@export var skill_icon: Texture2D
@export var skill_description: String
@export var skill_damage: float = 0.0
@export var skill_cooldown: float

@export var skill_range: GameDictionary.AtkRange
@export var cast_time: GameDictionary.CastTime
