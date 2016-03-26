$(document).ready(function() {
  $('.domain_user_edit').click(function(e) {
    var attributes;
    e.preventDefault();
    attributes = $(this).data('attributes');
    $.each(attributes, function(key, value) {
      if (key === '_id') {
        return $('#addDomainUser #new_user').attr({
          action: '/users/' + value,
          method: 'patch'
        });
      } else {
        return $('#user_' + key).val(value);
      }
    });
    $('ul.form-errors').html('');
    $('#addDomainUser').modal('show');
    return true;
  });

  $('#addDomainUser').on('show.bs.modal', function(e) {
    console.log("e.target");
    console.debug(e.relatedTarget);
    if ($(e.relatedTarget).attr('id') !== 'domain_user_new') {
      return true;
    }
    $.each($('#addDomainUser #new_user input:text'), function(key, element) {
      return $(element).val('');
    });
    $('ul.form-errors').html('');
    return true;
  });

})
