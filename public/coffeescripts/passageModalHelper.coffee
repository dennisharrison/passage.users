@passageModalOpen = (html) ->
	$("#PassageModalHelperBody").html(html)
	$("#PassageModalHelper").find("[action='cancel']:last").attr('data-dismiss', 'modal')
	$("#PassageModalHelper").find("[action='save']:last").attr('data-dismiss', 'modal')
	$('#PassageModalHelper').modal('show')