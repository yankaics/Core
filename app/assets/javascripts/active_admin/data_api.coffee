data_api_schema_table_editable = ->
  $('.data_api_schema_table.editable a.delete').unbind().click (e) ->
    $(@).parent().parent().remove()
    data_api_schema_table_editable()

  $('.data_api_schema_table.editable a.add').unbind().click (e) ->
    rand = "#{data_api_schema_rand_str()}-#{data_api_schema_rand_str()}-#{data_api_schema_rand_str()}"
    $newRow = $(@).parent().parent().clone()
    oldUuid = $newRow.find('input').attr('name').match(/\[schema\]\[([^\]]+)\]/)[1]
    $newRow.html $newRow.html().replace(new RegExp(oldUuid, 'g'), rand)
    $(@).parent().parent().parent().append($newRow)
    $(@).addClass('delete').removeClass('add').html('-')
    data_api_schema_table_editable()

data_api_schema_rand_str = ->
  Math.floor((1 + Math.random()) * 0x10000).toString(16)

$ ->
  data_api_schema_table_editable()
