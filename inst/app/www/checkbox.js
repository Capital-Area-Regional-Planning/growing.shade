$(document).ready(function(){
  $('input[name=map_selections_ui_1-theme2]').on('click', function(event){
    if($('input[name=map_selections_ui_1-theme2]:checked').length > 2){
      $(this).prop('checked', false);
    }
  });
  $('input[name=map_selections_ui_1-theme2]').on('click', function(event){
    if($('input[name=map_selections_ui_1-theme2]:checked').length == 0){
      $(this).prop('checked', true);
    }
  });
});