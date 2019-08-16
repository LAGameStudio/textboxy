/// @desc Returns the coordinates of a TbyBubble, given the speaking instance and dimensions.
/// @param _inst
/// @param _w_pos
/// @param _h_pos
var _inst = argument0, _w_pos = argument1, _h_pos = argument2;

var _offset = tby_bubble_calculate_offset(_inst, _w_pos, _h_pos)

return [_offset[0], _offset[1], _w_pos, _h_pos]