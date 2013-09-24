@actionSaveHelper = (ui) ->
	ui = $(ui)
	root = ui.closest("[passage_item_root='true']")
	passage_name = root.attr('passage')
	passage = window["#{passage_name}_passage"]
	
	_id = root.attr('_id')

	unindexed_data = root.serializeArray()
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
	root = ui.closest("[passage_item_root='true']")
	passage_name = root.attr('passage')
	passage = window["#{passage_name}_passage"]

	data = {}
	data._rev = root.attr('_rev')
	data._id = decodeURIComponent(root.attr('_id'))

	socket = window["#{passage_name}_socket"]
	socket.emit('destroy', data)

@actionEditHelper = (ui) ->
	ui = $(ui)
	root = ui.closest("[passage_item_root='true']")
	passage_name = root.attr('passage')
	passage = window["#{passage_name}_passage"]

	data = {}
	data._rev = root.attr('_rev')
	data._id = root.attr('_id')
	console.log(data)

	$.ajax({
		url: "/#{passage.name}.edit"
		type: "get"
		data: data
		dataType: "json"
		success: (data) ->
			passageModalOpen(returnFormElements(users_passage, {doc: data}))
		})


$(document).on('click', "[action='save']", (e) ->
	e.preventDefault()
	actionSaveHelper(this)
	)

$(document).on('click', "[action='edit']", (e) ->
	e.preventDefault()
	actionEditHelper(this)
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