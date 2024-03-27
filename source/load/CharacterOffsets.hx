package load;

typedef DoidoOffsets = {
	var animOffsets:Array<Array<Dynamic>>;
	var globalOffset:Array<Float>;
	var cameraOffset:Array<Float>;
	var ratingsOffset:Array<Float>;
}

class CharacterOffsets
{
	public static function defaultOffsets():DoidoOffsets
	{
		return {
			animOffsets: [
				//["idle",0,0],
			],
			globalOffset: [0,0],
			cameraOffset: [0,0],
			ratingsOffset:[0,0]
		};
	}
}