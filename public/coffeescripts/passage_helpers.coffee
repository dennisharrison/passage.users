@returnElements = (passage, options) ->
	name = "#{passage.form_name}-new"
	classes = passage.classes || ""
	
	if options?.doc
		doc = options.doc
		name = doc._id

	rendered = "<form _id='#{name}' class='passage_form #{classes}' role='form'>"

	for name of passage.elementGroups
		group = passage.elementGroups[name]
		rendered += "<div class='element_group #{name}'>"
		for field of group
			element = group[field]
			context = {}
			context.name = field

			if element.label? and typeof element.label is 'string'
				context.label = element.label
			if not element.label? or (element.label? and element.label is true)
				context.label = field.titleize()
			if element.label? and element.label is false
				delete context.label

			if element.placeholder? and typeof element.placeholder is 'string'
				context.placeholder = element.placeholder
			if not element.placeholder? or (element.placeholder? and element.placeholder is false)
				delete context.placeholder
			if element.placeholder? and element.placeholder is true
				context.placeholder = field.titleize()

			if element.action? and typeof element.action is 'string'
				context.action = element.action
				context.passage_name = passage.name
			if not element.action? or (element.action? and element.action is true)
				context.action = field
				context.passage_name = passage.name
			if element.action? and element.action is false
				delete context.action

			if element.classes? and typeof element.classes is 'string'
				context.classes = element.classes

			if element.glyphicon? and typeof element.glyphicon is 'string'
				context.glyphicon = element.glyphicon

			if field is 'destroy' and typeof doc is 'undefined'
				continue
			
			if doc and typeof doc[field] isnt 'undefined'
				context.value = doc[field]
			partial = Handlebars.partials["elements/#{element.type}"](context)
			rendered += partial
		rendered += "</div>"
	rendered += "</form>"

	return rendered