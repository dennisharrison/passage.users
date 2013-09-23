(function() {
  Handlebars.registerHelper('elementsHelper', function(context, options) {
    console.log(context, options);
    return context;
  });

}).call(this);

/*
//@ sourceMappingURL=handlebars_helpers.js.map
*/