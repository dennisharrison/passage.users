// Reactivity is achieved by listening to the collections
// changes stream.  On a change for this collection update
// either the item or add the item to the UI.
var reactivity = function(passage){
  // Make sure the collection name is all lowercase.
  var collection = passage.name.toLowerCase(),
      rows,
      doc,
      template,
      show,
      ui,
      rev,
      _id,
      socket,
      socket_uri,
      socket_event,
      list_order_uri,
      list_json_uri

  socket_uri = "/" + collection;
  socket_event = "" + collection + "_change";
  list_order_uri = "" + socket_uri + ".order";
  list_json_uri = "" + socket_uri + ".json";
  show = passage.show

  socket = io.connect(socket_uri);

  var change_callback = function (change) {
    var _doc = change.doc
    var _doc_ui = $("[_id='" + encodeURIComponent(_doc._id) + "']");
    if(_doc_ui.length >= 1){
      if(change.deleted === true) {
        _doc_ui.remove();
        return;
      }
      var rev = _doc_ui.attr('_rev');  
      if(rev != _doc._rev){
        var options = {
          doc: _doc
        }
        var template = returnListItem(passage, options);
        _doc_ui.replaceWith(template);
      }
    } else {
      $.ajax({
        url: list_order_uri,
        dataType: 'json',
        type: 'get',
        success: function(data){
          rows = data;
          var i = 0
          _.each(data.rows, function(row){
            var options = {
                doc: _doc
              }
            var template = returnListItem(passage, options);
            if(row.id == _doc._id){
              if(typeof data.rows[i-1] == 'undefined') {
                $("[list_for='" + passage.name + "']").prepend(template);
              } else {
                var previous_element = $("[_id='" + data.rows[i-1].id + "']");
                previous_element.after(template);
              }
            }
            i ++  
          })
        }
      });
    }
  };

  socket.on(socket_event, change_callback);
  return socket
}

var initializeList = function (passage) {
  var collection = passage.name.toLowerCase(),
      rows,
      doc,
      template,
      show,
      ui,
      rev,
      _id,
      socket,
      socket_uri,
      socket_event,
      list_order_uri,
      list_json_uri


  ui = $("[list_for='" + passage.name + "']");
  socket_uri = "/" + collection;
  socket_event = "" + collection + "_change";
  list_order_uri = "" + socket_uri + ".order";
  list_json_uri = "" + socket_uri + ".json";
  show = passage.show

  $.ajax({
    url: list_json_uri,
    dataType: 'json',
    type: 'get',
    success: function(data){
      _.each(data.rows, function(_doc){
        var options = {
          doc: _doc.value
        }
        //var html = returnListItemElements(passage, options);
        var template = returnListItem(passage, options);
        ui.append(template);
      });
    }
  });
};