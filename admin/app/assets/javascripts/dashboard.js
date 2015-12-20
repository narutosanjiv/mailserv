$(document).ready(function(){
  $('.fetch_graph_btn').on('click', function(argument) {
    var val = $(this).data('value');
    graph_type_array = ["cpu", "memory", "swap"];
    for(i =0 ; i < graph_type_array.length; i++){
      img_src = "/images/munin/" + graph_type_array[i] + "-" + val + ".png";
      $($('.tab-content .tab-pane').get(i)).find('img').attr('src', img_src);
    }

  });

});
