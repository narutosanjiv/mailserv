# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#dataTable-Domain').DataTable {
    responsive: true
    dom: '<"pull-left"l><"pull-right"f><t>p'
  }

  $('.domain_edit').click (e) ->
    e.preventDefault()

    attributes = $(this).data('attributes')
    # Set input fields according to selected administrator's attributes
    # Also, set form action to update selected administrator
    $.each attributes, (key, value) ->
      if key == '_id'
        $('#new_domain').attr({ action: '/domains/' + value, method: 'patch' })
      else
        $('#domain_' + key).val(value);

    # Clear all errors
    $('ul.form-errors').html('')

    # Open up modal
    $('#addDomain').modal('show')
