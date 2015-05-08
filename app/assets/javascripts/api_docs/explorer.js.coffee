#= require swagger-ui

$ ->
  # Load SwaggerUI
  $('.api-explorer').each (index, element) ->
    id = $(element).attr('id')
    url = $(element).attr('data-url')

    window.swaggerUi = new SwaggerUi(
      url: url
      dom_id: id
      supportedSubmitMethods: [
        'get'
        'post'
        'put'
        'patch'
        'delete'
      ]

      onComplete: (swaggerApi, swaggerUi) ->
        $swaggerUi = $("##{swaggerUi.dom_id}")
        access_token = $swaggerUi.attr('data-access-token')

        $swaggerUi.children('.info').after("""
          <div class="access_token" id="api_access_token">
            <input id="input_api_access_token"
                   placeholder="access_token" type="text">
            <select id="select_api_access_token_authorization_method">
              <option value="url_param">URI Query Parameter</option>
              <option value="header">Authorization Request Header</option>
            </select>
          </div>
          """)

        $('#api_access_token').change(changeAccessTokenAuthorization)

        if access_token and access_token.trim() != ''
          $('#input_api_access_token').val(access_token)
          changeAccessTokenAuthorization()

      onFailure: (data) ->
        console.log 'Unable to Load SwaggerUI'

      docExpansion: 'list')

    window.swaggerUi.load()

  # Handler on access_token changed
  changeAccessTokenAuthorization = ->
    access_token = encodeURIComponent($('#input_api_access_token').val())
    authorization_method =
      $('#select_api_access_token_authorization_method').val()

    if access_token and access_token.trim() != ''
      if authorization_method == 'url_param'
        apiAuth = new ApiKeyAuthorization('access_token', access_token, 'query')
      else if authorization_method == 'header'
        apiAuth =
          new ApiKeyAuthorization('Authorization',
            "Bearer #{access_token}", 'header')

      window.swaggerUi.api.clientAuthorizations.add 'access_token', apiAuth
      console.log "access_token: #{access_token}"
      console.log "authorization_method: #{authorization_method}"
