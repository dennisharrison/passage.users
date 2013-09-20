(function() {
  var egs, passage;

  this.actionSaveHelper = function(ui) {
    var form, indexed_data, passage, passage_name, socket, unindexed_data, _id;
    ui = $(ui);
    passage_name = ui.attr('passage');
    passage = window["" + passage_name + "_passage"];
    form = ui.closest('form');
    _id = form.attr('_id');
    unindexed_data = form.serializeArray();
    indexed_data = {};
    $.map(unindexed_data, function(n, i) {
      return indexed_data[n['name']] = n['value'];
    });
    if (_id !== ("" + passage.form_name + "-new")) {
      indexed_data._id = _id;
    }
    socket = window['user_socket'];
    return socket.emit('upsert', indexed_data);
  };

  $(document).on('click', "[action='save']", function() {
    return actionSaveHelper(this);
  });

  this.passageModalOpen = function(html) {
    $("#PassageModalHelperBody").html(html);
    $("#PassageModalHelper").find("[action='cancel']:last").attr('data-dismiss', 'modal');
    return $('#PassageModalHelper').modal('show');
  };

  this.returnElements = function(passage, options) {
    var classes, context, doc, element, field, group, name, partial, rendered;
    name = "" + passage.form_name + "-new";
    classes = passage.classes || "";
    if (options != null ? options.doc : void 0) {
      doc = options.doc;
      name = doc._id;
    }
    rendered = "<form _id='" + name + "' class='passage_form " + classes + "' role='form'>";
    for (name in passage.elementGroups) {
      group = passage.elementGroups[name];
      rendered += "<div class='element_group " + name + "'>";
      for (field in group) {
        element = group[field];
        context = {};
        context.name = field;
        if ((element.label != null) && typeof element.label === 'string') {
          context.label = element.label;
        }
        if ((element.label == null) || ((element.label != null) && element.label === true)) {
          context.label = field.titleize();
        }
        if ((element.label != null) && element.label === false) {
          delete context.label;
        }
        if ((element.placeholder != null) && typeof element.placeholder === 'string') {
          context.placeholder = element.placeholder;
        }
        if ((element.placeholder == null) || ((element.placeholder != null) && element.placeholder === false)) {
          delete context.placeholder;
        }
        if ((element.placeholder != null) && element.placeholder === true) {
          context.placeholder = field.titleize();
        }
        if ((element.action != null) && typeof element.action === 'string') {
          context.action = element.action;
          context.passage_name = passage.name;
        }
        if ((element.action == null) || ((element.action != null) && element.action === true)) {
          context.action = field;
          context.passage_name = passage.name;
        }
        if ((element.action != null) && element.action === false) {
          delete context.action;
        }
        if ((element.classes != null) && typeof element.classes === 'string') {
          context.classes = element.classes;
        }
        if ((element.glyphicon != null) && typeof element.glyphicon === 'string') {
          context.glyphicon = element.glyphicon;
        }
        if (field === 'destroy' && typeof doc === 'undefined') {
          continue;
        }
        if (doc && typeof doc[field] !== 'undefined') {
          context.value = doc[field];
        }
        partial = Handlebars.partials["elements/" + element.type](context);
        rendered += partial;
      }
      rendered += "</div>";
    }
    rendered += "</form>";
    return rendered;
  };

  this.users_passage = {};

  passage = users_passage;

  passage.name = "users";

  passage.form_name = "UserForm";

  passage.classes = "user_form";

  passage.show = 'users/show';

  passage.elementGroups = {};

  egs = passage.elementGroups;

  egs.Info = {
    full_name: {
      type: 'input_text',
      label: false,
      placeholder: 'What is YOUR NAME?!',
      validation: ['required', 'custom_validator', 'alpha_only']
    },
    email: {
      type: 'input_text',
      label: 'L-Mail',
      validation: ['required', 'email_validator']
    },
    password: {
      type: 'input_password',
      placeholder: 'secreatsz',
      validation: ['required']
    },
    password_confirmation: {
      type: 'input_password',
      validation: ['required']
    }
  };

  egs.Controls = {
    destroy: {
      type: 'button',
      action: 'destroy_with_confirm',
      glyphicon: 'remove',
      classes: 'btn-danger'
    },
    cancel: {
      type: 'button',
      action: 'cancel',
      glyphicon: 'ban-circle',
      classes: 'btn-warning'
    },
    save: {
      type: 'button',
      action: 'save',
      glyphicon: 'ok',
      classes: 'btn-success'
    }
  };

}).call(this);

/*
//@ sourceMappingURL=public.js.map
*/