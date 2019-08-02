/// @desc Handles the given TbyBranch command and then calls the next entry.
/// @param branchName
/// @param tbData
var branchName = argument0, tbData = argument1;

var tbType = tbData[0];
var tbArgs = [];
var hasArgs = false;

// Copy args if there are any
if (tby_arrlen(tbData) > 1) {
    hasArgs = true;
    array_copy(tbArgs, 0, tbData, 1, tby_arrlen(tbData)-1)
}

#region ChoiceResult
// first, check for ChoiceResult. Since there can be a nested
// TbyType action, just unfold it
if (tbType == TbyType.ChoiceResult) {
    if (hasArgs && tbArgs[0] == global.tby_choice_result) {
        //0: Choice num to match
        //1: New type (or quick mode string etc.)
        //2: ... usual payload
        
        var newType = tbArgs[1];
        
        if (tby_arrlen(tbArgs) > 2) {
            // we have actual args and not only
            // Type.ChoiceResult + Result number + "type"
            
            var newArgs = [];
            array_copy(newArgs, 0, tbArgs, 2, tby_arrlen(tbArgs)-1);
            
            tbArgs = 0;
            tbArgs = newArgs;
        } else {
            // We dont have any further args, probably quick mode
            tbArgs = [];
            hasArgs = false;
        }
        
        tbType = newType;
    } else {
        // skip this entry
        tby_branch_next_entry(branchName)
    }
}
#endregion

#region Quick Modes
if (!hasArgs && is_string(tbType)) {
    // just a string, imply simple text box
    // If bubble char is first char, use TbyType.Bubble
    // Otherwise, use TbyType.Normal
    
    var s = tbType;
    tbType = 0;
    tbArgs = 0;
    
    if (string_char_at(s, 1) == tby_quick_mode_bubble_char) {
        // Bubble Mode
        tbType = TbyType.Bubble
        // Strip the extra character
        tbArgs[0] = string_delete(s, 1, 1)
    } else {
        // Normal Mode
        tbType = TbyType.Normal
        tbArgs[0] = s
    }
}

// This is the case when there is a Batch entry with
// quick modes
if (hasArgs && is_string(tbType)) {
    var isBubble, type;
    isBubble = string_char_at(tbType, 1) == tby_quick_mode_bubble_char

    // prepend type (= string) to args
    var newArgs = tby_concat([tbType], tbArgs);
    tbArgs = 0;
    tbArgs = newArgs;
    
    // then overwrite type with new type
    tbType = isBubble ? TbyType.Bubble : TbyType.Normal;
    
    
    // Delete bubble char
    if (isBubble) tbArgs[0] = string_delete(tbArgs[0], 1, 1)
}

#endregion

switch (tbType) {
    case TbyType.Normal:
        // 0: string
        // 1: positional data
        
        // global position data if none given
        if (tby_arrlen(tbArgs) < 2) tbArgs[1] = tby_branch_get_option(branchName, TbyOption.SetPlacement)
        
        tby_normal_create(tbArgs[0], tbArgs[1]);
    break;
    case TbyType.Bubble:
        // 0: string
        // 1: instance talking
        
        //use global instance if none is given
        if (tby_arrlen(tbArgs) < 2) tbArgs[1] = tby_branch_get_option(branchName, TbyOption.SetInstance)
        
        // check if its a string thats an object type (from json usually)
        if (is_string(tbArgs[1])) {
            var objectId = asset_get_index(tbArgs[1]);
            if (objectId != -1) tbArgs[1] = objectId
        } else if (tbArgs[1] == undefined || !instance_exists(tbArgs[1])) {
            // sanity check
            tby_log("No valid instance specified for bubble textbox, using ", id, "as substitute.")
            tbArgs[1] = id //just use the calling instance
        }
        
        tby_bubble_create(tbArgs[0], tbArgs[1])
    break;
    case TbyType.Choice:
        // 0: string
        // 1: choiceArray
        // 2: positional data
        if (tby_arrlen(tbArgs) < 3) tbArgs[2] = TbyPlacement.Auto;
        tby_choice_create(tbArgs[0], tbArgs[1], tbArgs[2]);
    break;
    case TbyType.Option:
        // 0: Option type
        // 1: Option value
        tby_branch_set_option(branchName, tbArgs[0], tbArgs[1])
        tby_branch_next_entry(branchName)
    break;
    case TbyType.Wait:
        // wait time
        with (tby_object_manager) alarm[0] = room_speed*tbArgs[0]
    break;
    case TbyType.Batch:
        // 0: array of other textboxes
        if (is_array(tbArgs[0])) {
            tby_handle_batch_entry(tbArgs[0]);
        }
    break;
    case TbyType.Terminate:
        var list = tby_branch_get_message_list(branchName);
        tby_list_clear(list);
        tby_branch_next_entry(branchName);
    break;
    case TbyType.Label:
        // 0: label name
        // Because of pre-scan, this does nothing at runtime
        tby_branch_next_entry(branchName);
    break;
    case TbyType.GoTo:
        // 0: label name
        var labelPointer = tby_branch_get_label(branchName, tbArgs[0])
        if (labelPointer != undefined) {
            var list = tby_branch_get_message_list(branchName);
            tby_list_set_pointer(list, labelPointer);
        }
        tby_branch_next_entry(branchName);
    break;
}