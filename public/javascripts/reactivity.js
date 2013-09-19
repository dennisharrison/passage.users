// Reactivity is achieved by listening to the collections
// changes stream.  On a change for this collection update
// either the item or add the item to the UI.
var reactivity = function(collection, partial){
  // Make sure the collection name is all lowercase.
  var collection = collection.toLowerCase(),
      rows,
      doc,
      template,
      ui,
      rev,
      _id,
      socket,
      socket_uri,
      socket_event,
      list_index_uri

  socket_uri = "/" + collection;
  socket_event = "" + collection + "_change";
  list_index_uri = "" + socket_uri + ".order";

  socket = io.connect(socket_uri);

  var change_callback = function (change) {
    var _doc = change.doc
    var _doc_ui = $("[_id='" + _doc._id + "']");
    if(_doc_ui.length >= 1){
      var rev = _doc_ui.find('.rev');  
      if(rev != _doc._rev){
        var rev = _doc._rev.split('-')[0];
        _doc.rev = rev;
        var template = Handlebars.partials[partial](_doc)
        _doc_ui.replaceWith(template);
      }
    } else {
      $.ajax({
        url: list_index_uri,
        dataType: 'json',
        type: 'get',
        success: function(data){
          rows = data;
          var i = 0
          _.each(data.rows, function(row){
            if(row.id == _doc._id){
              var previous_element = $("[_id='" + data.rows[i-1].id + "']");
              var template = Handlebars.partials[partial](_doc)
              previous_element.after(template);
            }
            i ++  
          })
        }
      });
    }
  };

  socket.on(socket_event, change_callback);
}