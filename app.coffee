
# /**
#  * Module dependencies.
#  */

# DB Server credentials
username = "SetMeUp"
password = "password"
hostname = "localhost:5984"
DBUrl = "http://#{username}:#{password}@#{hostname}"

express = require('express')
routes = require('./routes')
http = require('http')
path = require('path')
exphbs  = require('express3-handlebars')
global.nano = require('nano')(DBUrl)

app = express()

# // all environments
app.set('port', process.env.PORT || 3000)
app.engine('handlebars', exphbs({defaultLayout: 'main'}))
app.set('view engine', 'handlebars')
app.set('views', __dirname + '/views')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(app.router)
app.use(express.static(path.join(__dirname, 'public')))

# // development only
if 'development' is app.get('env')
  app.use(express.errorHandler())

app.get('/', routes.index)

module.exports = app
http.createServer(app).listen(app.get('port'), () ->
  console.log('Express server listening via Grunt on port ' + app.get('port'))
)
