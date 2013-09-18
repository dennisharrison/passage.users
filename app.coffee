
# /**
#  * Module dependencies.
#  */

express = require('express')
routes = require('./routes')
http = require('http')
path = require('path')
fs = require('fs')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
util = require('util')
clc = require('cli-color')
exphbs  = require('express3-handlebars')

# Pull in config
if fs.existsSync('config.js') is true
	database = require('./config').config.database
else
	# DB Server credentials
	database = {}
	database.username = ""
	database.password = ""
	database.hostname = "localhost:5984"
	database.protocol_prefix = "http://"

if database.username isnt "" and database.password isnt ""
	database.DBUrl = "#{database.protocol_prefix}#{database.username}:#{database.password}@#{database.hostname}"
else
	database.DBUrl = "#{database.protocol_prefix}#{database.hostname}"
	
hostname = database.hostname

global.nano = require('nano')(database.DBUrl)


# Setup logging functions
inspect = (message) ->
	util.log(util.inspect(message, {colors:true}))

notice = clc.cyanBright.bold
error = clc.red.bold
warn = clc.yellow
log = (message, level = notice) ->
	util.log(level(message))

bootstrapUsers = (db_name, callback) ->
	# Check for existence of passage_users DB and create it if needed.
	global.nano.db.get(db_name, (err, body) ->
			if err?.error is 'not_found'
				log("Missing #{db_name} @ #{hostname}", warn)
				global.nano.db.create(db_name, (err, body) ->
					if err
						inspect(err)
					else
						log("Created #{db_name} @ #{hostname}")
						bootstrapUsers(db_name, callback)
					)
			else
				log("Found #{db_name} @ #{hostname} - Now running callback...")
				if typeof callback is 'function'
					callback(body)
		)

# Authenticate!
users = global.nano.use('passage_users')
passport.use(new LocalStrategy((username, password, done) ->
	users.get(username, (err, user) ->
		inspect(user)
		if err
			return done(null, false, {message: "Invalid user: #{username}"})
		if user.password isnt password
			return done(null, false, {message: 'Invalid password'})
		return done(null, user)
		)
	))

# Configure your admin user
admin_user =
	email_address: "devteam@aeonstructure.com"
	password: "password"

bootstrapUsers('passage_users',(body) ->
	#Add admin user
	db_name = body.db_name
	users.get('admin', (err, body) ->
		if err
			if err.error is 'not_found'
				log("'admin' user missing", warn)
				users.insert(admin_user, 'admin', (err, body) ->
					if err
						log(err, error)
					else
						log("'admin' user with password '#{admin_user.password}' created in #{db_name} @ #{hostname}")
					)
			else
				inspect(err)
		else
			log("'admin' user found in #{db_name} @ #{hostname}")
		)
	#console.log body
	)


passport.serializeUser((user, done) ->
	done(null, user._id)
)

passport.deserializeUser((id, done) ->
	users.get(id, (err, user) ->
		done(err, user)
		)
)

app = express()

# // all environments

app.configure(()->
	app.set('port', process.env.PORT || 3000)
	app.engine('html', exphbs({defaultLayout: 'main',partialsDir: path.join(__dirname,"views/partials/"),extname: ".html"}))
	app.set('view engine', 'html')
	app.set('views', __dirname + '/views')
	app.use(express.favicon())
	app.use(express.logger('dev'))
	app.use(express.bodyParser())
	app.use(express.methodOverride())

	app.use(express.cookieParser())

	app.use(express.session({ cookie: { maxAge: 60000 },secret: 'keyboard cat'}))
	app.use(passport.initialize())
	app.use(passport.session())
	app.use(app.router)
	app.use(express.static(path.join(__dirname, 'public')))
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

module.exports = app
http.createServer(app).listen(app.get('port'), () ->
  console.log('Express server listening via Grunt on port ' + app.get('port'))
)
