@users_passage = {}
passage = users_passage
passage.name = "users"
passage.form_name = "UserForm"
passage.classes = "user_form"
passage.show = 'users/show'
passage.elementGroups = {}
egs = passage.elementGroups
egs.Info =
	full_name: {type:'input_text', label:false, placeholder:'What is YOUR NAME?!', validation:['required', 'custom_validator', 'alpha_only']}
	email: {type:'input_text', label:'L-Mail', validation:['required', 'email_validator']}
	password: {type:'input_password', placeholder:'secreatsz', validation:['required']}
	password_confirmation: {type:'input_password', validation:['required']}
	#roles: 'roles_editor'

egs.Controls =
	destroy: {type:'button', action:'destroy_with_confirm', glyphicon:'remove', classes:'btn-danger'}
	cancel: {type:'button', action:'cancel', glyphicon:'ban-circle', classes:'btn-warning'}
	save: {type:'button', action:'save', glyphicon:'ok', classes:'btn-success'}