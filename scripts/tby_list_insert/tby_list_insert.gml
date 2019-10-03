/// @desc Insert a value in a TbyList.
/// @param _tby_list
/// @param _pos
/// @param _val
var _tby_list/*:TbyList*/ = argument0, _pos = argument1, _val = argument2;

if (tby_list_exists(_tby_list)) {
    if (_pos+1 > tby_list_size(_tby_list)) {
        ds_list_add(_tby_list, _val);
    } else {
        ds_list_insert(_tby_list, _pos+1, _val);
    }
}