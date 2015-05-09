#= require swagger-ui
#= require chosen-jquery

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
        allScopes = JSON.parse $swaggerUi.attr('data-all-scopes')
        applications = JSON.parse $swaggerUi.attr('data-applications')

        scopeSelections = []
        for key, info of allScopes
          if info.default
            scopeSelections.push "<option selected value=\"#{key}\">#{key} (#{info.name})</option>"
          else
            scopeSelections.push "<option value=\"#{key}\">#{key} (#{info.name})</option>"

        applicationSelections = []
        for key, info of applications
          if key == 'api_docs_api_explorer'
            applicationSelections.push "<option selected value=\"#{key}\">#{info.name}</option>"
          else
            applicationSelections.push "<option value=\"#{key}\">#{info.name}</option>"

        $swaggerUi.children('.info').after("""
          <div class="access_token" id="api_access_token">
            App:
            <select id="select_application">
              #{applicationSelections.join()}
            </select>
            Scopes:
            <select multiple id="select_access_token_scope"
              data-placeholder="select some scopes">
              #{scopeSelections.join()}
            </select>
            <button id="button_get_access_token">
              Get Access Token
            </button>
            <br>
            Access Token:
            <input id="input_api_access_token"
                   placeholder="access_token" type="text">
            Authorize Method:
            <select id="select_api_access_token_authorization_method">
              <option value="url_param">URI Query Parameter</option>
              <option value="header">Authorization Request Header</option>
            </select>
          </div>
          """)

        $('#button_get_access_token').click(getAccessToken)
        $('#api_access_token').change(changeAccessTokenAuthorization)

        $('#select_application').chosen()
        $('#select_access_token_scope').chosen()

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

  window.changeAccessToken = (access_token) ->
    setTimeout( ->
      $('#input_api_access_token').val(access_token)
      changeAccessTokenAuthorization()
      $('#api_access_token').addClass('changed')
    , 500)
    setTimeout( ->
      $('#api_access_token').removeClass('changed')
    , 2000)

  getAccessToken = ->
    client_id = $('#select_application').val()
    scope = $('#select_access_token_scope').val().join('+')
    authorizeUrl = "/oauth/authorize?\
                    client_id=#{client_id}&\
                    scope=#{scope}&\
                    redirect_uri=/api_docs/explorer/oauth_callbacks&\
                    response_type=token"

    height = 640
    width = 640
    top = (screen.height/2.3) - (height/2)
    left = (screen.width/2) - (width/2)
    authDialog = window.open('', 'oauth_authorize',
      "height=#{height},width=#{width},top=#{top},left=#{left}")

    authDialog.location = authorizeUrl
