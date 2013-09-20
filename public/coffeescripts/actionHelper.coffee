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


	socket = window['user_socket']
	socket.emit('upsert', indexed_data)

$(document).on('click', "[action='save']", () ->
	actionSaveHelper(this)
	)