(function() {
  Handlebars.registerHelper('elementsHelper', function(context, options) {
    console.log(context, options);
    return context;
  });

  Handlebars.registerHelper('chopAtFirst', function(text, chop_char) {
    var value;
    value = text.split(chop_char)[0];
    return value;
  });

}).call(this);

/*
//@ sourceMappingURL=handlebars_helpers.js.map
*/