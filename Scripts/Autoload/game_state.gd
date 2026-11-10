extends Node

signal battle_loading_finished
var is_loading: bool = false

#Loadout
var skill_selected: int = 0
var skills: Array[SkillResource]

#Tutorial
var boss_1_tutorial_seen: bool = false
var boss1_intro_seen: bool =false
