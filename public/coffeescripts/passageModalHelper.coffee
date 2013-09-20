@passageModalOpen = (html) ->
	$("#PassageModalHelperBody").html(html)
	$("#PassageModalHelper").find("[action='cancel']:last").attr('data-dismiss', 'modal')
	$('#PassageModalHelper').modal('show')