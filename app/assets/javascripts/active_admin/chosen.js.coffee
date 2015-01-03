@chosenify = (entry) ->
  entry.chosen
    allow_single_deselect: true
    disable_search_threshold: 7

$ ->
  chosenify $(".chosen")

  $("form.formtastic .inputs .has_many").click ->
    $(".chosen").chosen
      allow_single_deselect: true
      disable_search_threshold: 7
