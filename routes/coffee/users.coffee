putils 			= require(__dirname + '/../lib/passage-utils')
inspect 		= putils.inspect
log 				= putils.log
DB 					= require(__dirname + '/../lib/users')
_couch 			= DB.connector
collection	= _couch.use('_users')

users = {}
users.order = {}
users.json = {}
users.index = {}
users.show = {}
users.edit = {}
users.update = {}
users.destroy = {}

users.order = (req, res) ->
	collection.view('users', 'users_by_name-id', (err, body) ->
		if err
			inspect(err)
			return
		if body
			res.send(body)
		)

users.json = (req, res) ->
	collection.view('users', 'users_by_name', (err, body) ->
		if err
			inspect(err)
			return
		if body
			res.send(body)
		)

users.index = (req, res) ->
	collection.view('users', 'users_by_name', (err, body) ->
		if err
			inspect(err)
			return
		if body
			res.render('user_index', { 'users': body })
		)

users.edit = (req, res) ->
	req.query._id = decodeURIComponent(req.query._id)
	collection.get(req.query._id, (err, body) ->
		if err
			inspect(err)
			return
		if body
			res.send(body)
		)	
	
users.show = (req, res) ->
	console.log(req)

exports.users = users