/// @desc Loads an external identifier from file and runs it in a new TbyBranch.
/// @param _identifier
var _identifier = argument0;

var _map = global.tby_external_strings_map;

if (_map != undefined && ds_exists(_map, ds_type_map)) {

	var _list = ds_map_find_value(_map, _identifier);

	if (_list != undefined) {
	    var _arr = tby_ds_list_to_array(_list);
	    tby_branch_create([_arr]);
	    tby_branch_run(_identifier);
	}

}