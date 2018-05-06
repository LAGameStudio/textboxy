///@function tbyActionShowString(string)
///@desc This should not be called manually
///@param string
var s = string_replace_all(argument0, "\r\n", "\n")
var l = tbyDivideStringToChunks(s);

draw_set_font(currentFont);

#region Insert smart line breaks
var stringBuilder = "";
for (var i = 0; i < ds_list_size(l); i++) {
	var e = ds_list_find_value(l, i);
	// Skip control codes
	if (string_length(e) > 1
		&& string_char_at(e, 1) == tbyControlCodeOpening) {
		continue;
	}
	
	// Reset the building string if we encounter a line break
	if (e == "\n") {
		stringBuilder = "";
		continue;
	}
	
	stringBuilder += string(e);
	
	// Check for max width line break insertion
	if (string_width(stringBuilder) > maxWidth) {
		tbyFindLineBreakPosition(l, i);
		i++;
		stringBuilder = "";
		continue;
	}
}
#endregion

//TODO: Make string building more efficient
/* What we are doing here is basically
splitting the string up, inserting line
breaks and putting it back together, only
to split it up again later for the control
code parsing. This is inefficient and could
be combined into a single step somehow. */

var cleanString = "";
var dirtyString = "";
for (var j = 0; j < ds_list_size(l); j++) {
	var c = ds_list_find_value(l, j);
	
	dirtyString += string(c);
	
	// Skip control codes
	if (string_char_at(c, 1) != tbyControlCodeOpening) {
		cleanString += string(c);
		//error(string_width(cleanString), cleanString)
	}
}

if (ds_exists(l, ds_type_list)) {
	ds_list_destroy(l);
}

#region Set up text instance
currentWidth = string_width(cleanString);
currentLines = string_count("\n", cleanString)+1;

//Apply position update
if (is_array(positionUpdate)) {
	var w = min(currentWidth, maxWidth)+tbyTileSize*2;
	var h = min(lineHeight*currentLines, lineHeight*maxLines)+tbyTileSize*2;
	var type = positionUpdate[TbyPositionUpdate.Type];
	
	var topLeftCoords, originCoords;
	
	var xx = positionUpdate[TbyPositionUpdate.X];
	var yy = positionUpdate[TbyPositionUpdate.Y];
	
	switch (type) {
		case TbyPositionUpdateType.TopLeft:
			topLeftCoords =	[xx, yy]
			originCoords =	[xx+floor(w/2), yy+h]
		break;
		case TbyPositionUpdateType.Origin:
			originCoords =	[xx, yy]
			topLeftCoords =	[xx-floor(w/2), yy-h]
		break;
	}
	positionUpdate = undefined;
	
	ox = originCoords[0];
	oy = originCoords[1];
	tlx = topLeftCoords[0];
	tly = topLeftCoords[1];
	
	// If we set topLeft, adjust the origin point
	// downwards
	if (type == TbyPositionUpdateType.TopLeft) {
		oy += floor(sprite_get_height(tbyBubbleSprite)/2)
	} else {
		// If se set origin, adjust the top corner upwards
		tly -= floor(sprite_get_height(tbyBubbleSprite)/2)
	}
	
}

with (tbyM()) {
	var textX = clamp(tlx, 0, screenW-currentWidth);
	var textY = clamp(tly, 0, screenH-currentLines*lineHeight);
	
	currentTextInstance = tbyT(cleanString, dirtyString, currentFont,
						textX, textY,
						currentWidth, currentLines*lineHeight,
						standardWait)
}
#endregion