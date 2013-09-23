@actionSaveHelper = (ui) ->
	ui = $(ui)
	passage_name = ui.attr('passage')
	passage = window["#{passage_name}_passage"]
	form = ui.closest('form')
	_id = form.attr('_id')

	unindexed_data = form.serializeArray()
	indexed_data = {}
	$.map(unindexed_data, (n, i) ->
		indexed_data[n['name']] = n['value']
		)

	if _id isnt "#{passage.form_name}-new"
		indexed_data._id = _id


	socket = window["#{passage_name}_socket"]
	socket.emit('upsert', indexed_data)

@actionDestroyHelper = (ui) ->
	ui = $(ui)
	passage_name = ui.attr('passage')
	passage = window["#{passage_name}_passage"]
	
	listing = ui.closest("[passage_listing_root='true']")

	data = {}
	data._rev = listing.attr('id')
	data._id = listing.attr('_id')

	socket = window["#{passage_name}_socket"]
	socket.emit('destroy', data)


$(document).on('click', "[action='save']", (e) ->
	e.preventDefault()
	actionSaveHelper(this)
	)

$(document).on('click', "[action='destroy']", (e) ->
	e.preventDefault()
	actionDestroyHelper(this)
	)

$(document).on('click', "[action='destroy_with_confirm']", (e) ->
	self = this
	e.preventDefault()
	confirmation = confirm("Are you sure?")
	if confirmation
		actionDestroyHelper(self)
	)