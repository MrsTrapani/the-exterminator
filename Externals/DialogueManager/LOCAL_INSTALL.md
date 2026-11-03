# Project installation

This plugin is installed at `res://Externals/DialogueManager` to keep external code in one folder.
The plugin and DialogueManager autoload are registered explicitly in project.godot.
Resource paths were relocated from res://addons/dialogue_manager.
The editor font size lookup was updated for Godot 4.7.
The built-in updater is disabled because upstream installs into addons and overwrites local patches.

For a manual update, preserve .uid files, replace the upstream files, relocate absolute resource paths,
and reapply the disabled updater and font setting compatibility change. Reopen the project and check
that the Dialogue editor, autoload, and example balloon load.
