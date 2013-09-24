@assert = (truthy, message) ->
	if(!truthy) 
		throw Error("Assertion failed: #{message}")

class @Passage
	constructor: (options) ->
		assert(typeof options != 'undefined', "options not defined")
		assert(options.name, 'options.name not defined')
		assert(typeof options.info != 'undefined', 'options.info not defined')
		@name = options.name
		
		@form_name = "#{@name}Form"
		@classes = "#{@name}_form"
		@show = "#{@name}/show"
		@list_partial = "#{@name}/list_item"
		@elementGroups = {}
		@egs = @elementGroups
		
		@egs.Info = options.info
		if options.FormControls
			@egs.FormControls = options.FormControls
		else
			@egs.FormControls =
				destroy: {type:'button', action:'destroy_with_confirm', glyphicon:'remove', classes:'btn-danger'}
				cancel: {type:'button', action:'cancel', glyphicon:'ban-circle', classes:'btn-warning'}
				save: {type:'button', action:'save', glyphicon:'ok', classes:'btn-success'}

		if options.ListControls
			@egs.ListControls = options.ListControls
		else
			@egs.ListControls =
				edit: {type:'button', action:'edit', glyphicon:'pencil', classes:'btn-info'}
				destroy: {type:'button', action:'destroy_with_confirm', glyphicon:'remove', classes:'btn-danger'}

	whoami: ->
		return @name

@returnFormElements = (passage, options) ->
	name = "#{passage.form_name}-new"
	rev = "0"
	classes = passage.classes || ""
	
	if options?.doc
		doc = options.doc
		name = encodeURIComponent(doc._id)
		rev = doc._rev

	rendered = "<form _id='#{name}' _rev='#{rev}' class='passage_form #{classes}' passage='#{passage.name}' passage_item_root='true' role='form'>"

	for name of passage.elementGroups
		if name is "ListControls"
			continue
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
			if field is 'edit' and typeof doc is 'undefined'
				continue
			
			if doc and typeof doc[field] isnt 'undefined'
				context.value = doc[field]
			partial = Handlebars.partials["elements/#{element.type}"](context)
			rendered += partial
		rendered += "</div>"
	rendered += "</form>"

	return rendered


@returnListItem = (passage, options) ->
	if options?.doc
		doc = options.doc
	else
		return
	id = encodeURIComponent(doc._id)
	rev = doc._rev
	context = {}
	context.passage = passage
	context.doc = options.doc
	context.passage_bind = "_rev=#{rev} _id=#{id} passage=#{passage.name} passage_item_root=true"

	rendered = Handlebars.partials["#{passage.list_partial}"](context)
	return rendered












#EOF