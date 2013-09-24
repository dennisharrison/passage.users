Handlebars.registerHelper('elementsHelper', (context, options) ->
	console.log(context, options)
	return context
	)

Handlebars.registerHelper('chopAtFirst', (text, chop_char) ->
	value = text.split(chop_char)[0]
	return value
	)