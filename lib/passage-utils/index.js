(function(){
	var util = require('util');
	var clc = require('cli-color');
	var notice = clc.cyanBright.bold;
	var error = clc.red.bold;
	var warn = clc.yellow;

	// Setup logging functions
	inspect = function(message) {
		util.log(util.inspect(message, {colors:true}))
	}
		
	log = function (message, level) {
		if(typeof level === 'undefined')
			level = notice
		util.log(level(message));
	}

	exports.inspect = inspect;
	exports.log = log;
	
})()