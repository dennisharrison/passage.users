
# /**
#  * Module dependencies.
#  */

express 	= require('express')
routes 		= require('./routes')
http 			= require('http')
path 			= require('path')
fs 				= require('fs')
passport 	= require('passport')
LocalStrategy = require('passport-local').Strategy
exphbs  	= require('express3-handlebars')
md5 			= require('MD5')
DB 				= require(__dirname + '/lib/users')
putils 		= require(__dirname + '/lib/passage-utils')
inspect 	= putils.inspect
log 			= putils.log
config 		= {}
	
hostname = DB.config.hostname
_couch = DB.connector
Collections = DB.Collections

configPath = path.resolve('./config.js')
if fs.existsSync('./config.js') is true
	configPath = configPath.replace('.js','')
	config = require(configPath).config
	

if not config.hasConfig
	throw "Please move config.js.sample to config.js and edit it for correctness."

Users = _couch.use('_users')
session_salt = config.session_salt

bootstrapAdmin = () ->
	# Check for existence of passage_users DB and create it if needed.
	admin_id = "org.couchdb.user:#{config.admin_user.name}"
	Users.get(admin_id, (err, body) ->
		if err?.error is 'not_found'
			log("Missing #{config.admin_user.name} @ #{hostname}/_users")
			upsertUser(config.admin_user)
		else
			log("Found #{config.admin_user.name} @ #{hostname}/_users - Good to go!")
	)

couchifyUserName = (userName) ->
	_id = "org.couchdb.user:#{userName}"
	if userName isnt _id
		userName = _id
	return userName

upsertUser = (userDoc) ->
	userDoc._id = couchifyUserName(userDoc.name)
	userDoc.modified_epoch = Date.now()
	userDoc.type = "user"
	Users.insert(userDoc, userDoc._id, (err, body) ->
		if err
			inspect(err)
			return
		log("Upserted #{userDoc.name} @ #{hostname}/_users")
		)

destroyUser = (userName) ->
	userName = couchifyUserName(userName)
	Users.get(userName, (err, body) ->
		if err
			inspect(err)
			return
		if body
			Users.destroy(userName, body._rev, (err, body) ->
				if err
					inspect(err)
					return
				if body
					log("Destroyed #{userName} @ #{hostname}/_users")
			)
	)

changeUserPassword = (userName, password) ->
	userName = couchifyUserName(userName)
	Users.get(userName, (err, body) ->
		if err
			inspect(err)
			return
		if body
			body.password = password
			log("Changing password for #{userName} @ #{hostname}/_users")
			upsertUser(body)
	)

# Authenticate!
passport.use(new LocalStrategy((username, password, done) ->
	username = "#{username}"
	_couch.auth(username, password, (err, user) ->
		if err
			inspect(err)
			return done(null, false, {message: "Invalid user: #{username}"})
		if user
			inspect(user)
			return done(null, user)
		)
	))

bootstrapAdmin()
#changeUserPassword(config.admin_user.name, "support2366apex")

passport.serializeUser((user, done) ->
	done(null, user.name)
)

passport.deserializeUser((name, done) ->
	id = "org.couchdb.user:#{name}"
	Users.get(id, (err, user) ->
		user.gravatar_hash = md5(user.name.toLowerCase())
		done(err, user)
		)
)

app = express()

version = JSON.parse(fs.readFileSync(__dirname + "/package.json")).version
hbsOptions =
	helpers:
		appVersion: () -> 
			return "v#{version}"
	defaultLayout: 'main'
	partialsDir: path.join(__dirname,"views/partials/")
	extname: ".html"

hbs = exphbs.create(hbsOptions)

# // all environments

app.configure(()->
	app.set('port', process.env.PORT || 3000)
	app.engine('html', hbs.engine)
	app.set('view engine', 'html')
	app.set('views', __dirname + '/views')
	app.use(express.favicon())
	app.use(express.logger('dev'))
	app.use(express.bodyParser())
	app.use(express.methodOverride())

	app.use(express.cookieParser())

	app.use(express.session({ cookie: { maxAge: 2628000000 },secret: session_salt}))
	app.use(passport.initialize())
	app.use(passport.session())
	app.use(app.router)
	app.use(express.static(path.join(__dirname, 'public')))
	)

exposePartials = (req, res, next) ->
	hbs.loadPartials({cache: app.enabled('view cache'), precompiled: true}, (err, partials) ->
		if err
			return next(err)
		extRegex = new RegExp("#{hbs.extname}$")
		partials_array = []
		for name of partials
			partial_obj = {}
			partial_obj.name = name.replace(extRegex, '')
			partial_obj.partial = partials[name]
			partials_array.push(partial_obj)

		if partials_array.length
			res.locals.partials = partials_array

		next()
	)

# // development only
if 'development' is app.get('env')
  app.use(express.errorHandler())

app.get('/', routes.index)
app.get('/login', (req, res) ->
	res.render('login', { user: req.user, message: req.session.messages }))

app.get('/logout', (req, res) ->
  req.logout()
  res.redirect('/')
)

#app.post('/login', routes.login.post)
app.post('/login', passport.authenticate('local', { 
	failureRedirect: '/login'
	successRedirect: '/'
	})
)

app.get('/users', exposePartials, routes.users.index)
app.get('/users.order', routes.users.order)

module.exports = app

io = require('socket.io').listen(app.listen(app.get('port')),{ log: false })
io.sockets.on('connection', (socket) ->
	io.sockets.emit('this', {will: 'be received by everyone'})
	)

users_socket = io.of('/users')
users_feed = Users.follow({since: "now", include_docs: true})
users_feed.on('change', (change) ->
	users_socket.emit('users_change', change)
	)
users_feed.follow()
# http.createServer(app).listen(app.get('port'), () ->
#   console.log('Express server listening via Grunt on port ' + app.get('port'))
# )
