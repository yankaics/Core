#= require swagger-ui
#= require chosen-jquery

$ ->
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
      console.log "access_token: #{access_token.substring(0, 8)}..."
      console.log "authorization_method: #{authorization_method}"

  # Popup an authorization window to get a new access token
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

  # Callback to change the access token
  window.changeAccessToken = (access_token) ->
    setTimeout( ->
      $('#input_api_access_token').val(access_token)
      changeAccessTokenAuthorization()
      $('#api_access_token').addClass('changed')
    , 100)
    setTimeout( ->
      $('#api_access_token').removeClass('changed')
    , 500)

  changeCollection = (e, logHistory = true) ->
    if typeof e == 'string'
      collection = e
    else
      collection = e.target.value
    api_base_url = $('#api-explorer-collection-selector').attr('data-api-base-url')
    api_base_url = api_base_url.replace(/\/$/, '')
    if collection == 'core'
      docs_url = "#{api_base_url}/docs"
    else
      docs_url = "#{api_base_url}/extend_docs?collection=#{collection}"

    window.swaggerUi = newSwaggerUiWithUrl('swagger-ui-wrap', docs_url)
    window.swaggerUi.load()

    if logHistory
      history.pushState({ collection: collection }, false, "?collection=#{collection}")

  # Load Authorizer
  $('#api-explorer-authorizer').each (index, element) ->
    access_token = $(element).attr('data-access-token')
    allScopes = JSON.parse $(element).attr('data-all-scopes')
    applications = JSON.parse $(element).attr('data-applications')

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

    $(element).html("""
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

  # Load API Collection Selector
  $('#api-explorer-collection-selector').each (index, element) ->
    api_collection = $(element).attr('data-api-collection')
    history.replaceState({ collection: api_collection }, false)
    api_collections = JSON.parse $(element).attr('data-api-collections')
    collectionSelections = []

    for key, name of api_collections
      if key == api_collection
        collectionSelections.push "<option selected value=\"#{key}\">#{name}</option>"
      else
        collectionSelections.push "<option value=\"#{key}\">#{name}</option>"

    $(element).html("""
      <div class="api_collection">
        API Collection:
        <select id="select_api_collection">
          #{collectionSelections.join()}
        </select>
      </div>
      """)
    $('#select_api_collection').chosen()
    $('#select_api_collection').change(changeCollection)


  $(window).on 'popstate', (e) ->
    data = e.originalEvent.state || {}
    if data.collection
      changeCollection(data.collection, false)
      $('#select_api_collection').val(data.collection)
      $('#select_api_collection').trigger('chosen:updated')

  # Load SwaggerUI
  newSwaggerUiWithUrl = (id, url) ->
    new SwaggerUi(
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
        changeAccessTokenAuthorization()

      onFailure: (data) ->
        console.log 'Unable to Load SwaggerUI'
        console.log data

      docExpansion: 'list')

  changeCollection($('#select_api_collection').val(), false)
