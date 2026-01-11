@tool
extends EditorPlugin

const PLUGIN_NAME := "AutoScrollContainer"

const PLUGIN_ICON := preload("./icon.svg")

func _get_plugin_name() -> String:
	return PLUGIN_NAME

func _get_plugin_icon() -> Texture2D:
	return PLUGIN_ICON
