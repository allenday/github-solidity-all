contract Logging {
    /////////////////////////////////////////
	// FIELDS
    /////////////////////////////////////////

	Logginglevel currentLevel = Logginglevel.Debug;


	/////////////////////////////////////////
    // TYPES
    /////////////////////////////////////////
	enum Logginglevel { Normal, Information, Debug }


    /////////////////////////////////////////
	// EVENTS
    /////////////////////////////////////////

	event Log(bytes message);
	event LogValue(bytes label, uint value);


    /////////////////////////////////////////
	// METHODS
    /////////////////////////////////////////

    // Logs a string message through Log event
	function logMessage(bytes msg, Logginglevel msgLevel) {
		if (msgLevel <= currentLevel) {
			Log(msg);
		}
	}

    // Logs a uint value through LogValue event
	function logValue(bytes label, uint value, Logginglevel msgLevel) {
		if (msgLevel <= currentLevel) {
			LogValue(label, value);
		}
	}
}












//end
