/// @desc Creates and returns a new TbyType.Normal textbox.
/// @param _branch
/// @param _content = ""
/// @param _placement = TbyPlacement.Auto
var _branch = argument[0];
var _content = argument_count > 1 ? argument[1] : "";
var _placement = argument_count > 2 ? argument[2] : TbyPlacement.Auto;

// convert enum position to actual TbyDim instance
var _dim/*:TbyDim*/ = tby_normal_dimensions_from_placement(_placement, tby_normal_lines_per_box);

// Replace text from string literals
_content = string_replace_all(_content,"\r\n","\n")
_content = string_replace_all(_content, "\t", "");

var _textbox_inst = instance_create_layer(_dim[TbyDim.x], _dim[TbyDim.y], tby_room_layer_name, objTbyTextbox)
with (_textbox_inst) {
	type = TbyType.Normal
	branch = _branch
	
    dimensions = _dim;
	text_raw = _content;
}
return _textbox_inst