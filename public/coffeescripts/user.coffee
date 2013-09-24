user_description =
	full_name: {type:'input_text', label:'Your Full Name Goes Here', placeholder:'Johnny Appleseed', validation:['required', 'custom_validator', 'alpha_only']}
	email: {type:'input_text', label:'E-Mail', validation:['required', 'email_validator']}
	password: {type:'input_password', placeholder:'secreatsz', validation:['required']}
	password_confirmation: {type:'input_password', validation:['required']}
	#roles: 'roles_editor'
@users_passage = new Passage({name: 'users', info: user_description});