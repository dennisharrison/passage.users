exports.login = {}

exports.login.get = (req, res) ->
	res.render('login', { user: req.user, message: req.session.messages })
	
exports.login.post = (req, res) ->
	console.log(req)
	global.passport.authenticate('local', (err, user, info) ->
		console.log(err)
		res.redirect('/')
		)