(function(){
	var passport 	= require('passport');
	var LocalStrategy = require('passport-local').Strategy;
	var path 			= require('path')
	var fs 				= require('fs')
	var database = {};

	// Pull in config
	var configPath = path.resolve('./config.js');
	if(fs.existsSync('./config.js') == true) {
		configPath = configPath.replace('.js','');
		database = require(configPath).config.database;
	} else {
		// Default DB Server credentials
		database.username = "";
		database.password = "";
		database.hostname = "localhost:5984";
		database.protocol_prefix = "http://";
	}

	if(database.username !== "" && database.password !== ""){
		var url = [];
		url.push(database.protocol_prefix);
		url.push(database.username);
		url.push(":");
		url.push(database.password);
		url.push("@");
		url.push(database.hostname);
		database.DBUrl = url.join('');
	} else {
		var url = [];
		url.push(database.protocol_prefix);
		url.push(database.hostname);
		database.DBUrl = url.join('');
	}

	var DB = require('nano')(database.DBUrl)
	var Collections = {};

	module.exports.connector = DB;
	module.exports.config = database;
	module.exports.Collections = Collections

})();