@tool
extends Control


signal failed()
signal updated(updated_to_version: String)


const TEMP_FILE_NAME: String = "user://temp.zip"


@onready var logo: TextureRect = %Logo
@onready var label: Label = $VBox/Label
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var download_button: Button = %DownloadButton

var next_version_release: Dictionary:
	set(value):
		next_version_release = value
		label.text = DMConstants.translate(&"update.is_available_for_download") % value.tag_name.substr(1)
	get:
		return next_version_release


func _ready() -> void:
	$VBox/Center/DownloadButton.text = DMConstants.translate(&"update.download_update")
	$VBox/Center2/NotesButton.text = DMConstants.translate(&"update.release_notes")


#region Signals


func _on_download_button_pressed() -> void:
	# This project keeps plugins under Externals. Upstream's updater reinstalls
	# under addons and overwrites the relocation patches, so use manual updates.
	push_warning("Dialogue Manager lives in Externals/DialogueManager. Update manually and preserve the relocated resource paths.")
	failed.emit()


func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	# Automatic installation is disabled for this relocated copy.
	failed.emit()


func _on_notes_button_pressed() -> void:
	OS.shell_open(next_version_release.html_url)


#endregion
