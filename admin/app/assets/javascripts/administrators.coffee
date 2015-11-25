$ ->
  $('#dataTable-Administrator').DataTable {
    responsive: true
    dom: '<"pull-left"l><"pull-right"f><t>p'
  }

  $('.administrator_edit').click (e) ->
    e.preventDefault()

    attributes = $(this).data('attributes')

    # Set input fields according to selected administrator's attributes
    # Also, set form action to update selected administrator
    $.each attributes, (key, value) ->
      if key == '_id'
        $('#new_administrator').attr({ action: '/administrators/' + value, method: 'patch' })
      else
        $('#administrator_' + key).val(value);

    # Clear all errors
    $('ul.form-errors').html('')

    # Open up modal
    $('#addAdmin').modal('show')

  $('#administrator_new').click (e) ->
    e.preventDefault()

    # Clear all input fields
    $.each $('#new_administrator input:text'), (key, element) ->
      $(element).val('')

    # Clear all errors
    $('ul.form-errors').html('')

    # Set form action to create administrator
    $('#new_administrator').attr({ action: '/administrators', method: 'post' })

    # Open up modal
    $('#addAdmin').modal('show')
