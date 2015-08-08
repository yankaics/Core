ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

NewUserEmailBox = React.createClass
  mixins: [React.addons.LinkedStateMixin]
  propTypes:
    emailPatterns: React.PropTypes.array

  getInitialState: ->
    email: ''
    departments: {}
    cached_departments: {}
    organization_code: '?'
    organization_name: '?'
    uid: null
    corresponded_identity: null
    identity_detail: null
    department_code: '?'
    department_name: '?'
    department: null
    started_at: null
    permit_changing_department_in_group: null
    permit_changing_department_in_organization: null
    submitActivate: false
    i: 1

  componentWillMount: ->
    for emailPattern in @props.emailPatterns
      emailPattern.email_fixed_suffix_regexp = emailPattern.email_regexp.match(/[@a-z0-9\.\\\$]+$/)[0]
      emailPattern.email_fixed_suffix = emailPattern.email_fixed_suffix_regexp.replace(/\\\./g, '.').replace(/[^@A-Za-z0-9\.]/g, '')
      emailPattern.email_regexp_without_fixed_suffix = emailPattern.email_regexp.replace(/[@a-z0-9\.\\\$]+$/, '')
      sp = emailPattern.email_regexp.split('@')
      emailPattern.email_account_regexp = sp[0]
      emailPattern.email_domain_regexp = sp[1]

  componentDidMount: ->
    if @props.email?.email
      @setState
        email: @props.email?.email
      @handleEmailChange(@props.email?.email)

  _fetchDepartments: (organization_code) ->
    if @state.cached_departments[organization_code]
      @setState
        departments: @state.cached_departments[organization_code]
        @_UpdateDepartments()
    else
      $.ajax
        url: "/user_emails/query_departments.json?organization_code=#{organization_code}"
        dataType: 'json'
      .done @_fetchDepartmentsDone
      .fail @_fetchDepartmentsFail

  _fetchDepartmentsDone: (data, textStatus, jqXHR) ->
    @state.cached_departments[data.organization_code] = data
    @setState
      departments: data
    @_UpdateDepartments()

  _fetchDepartmentsFail: (xhr, status, err) =>
    console.error @props.url, status, err.toString()

  _lookupEmailDone: (data, textStatus, jqXHR) ->
    @handleEmailChange(data.email, data, true) if data

  _lookupEmailFail: (xhr, status, err) =>
    console.error @props.url, status, err.toString()

  _UpdateDepartments: ->
    @setState
      department: @state.departments[@state.department_code]
      department_name: @state.departments[@state.department_code]?['name']

  handleEmailChange: (email, outerMatchEmailPattern, outerFound) ->
    @setState
      email: email
      organization_name: null
      uid: null
      corresponded_identity: null
      identity_detail: null
      organization_code: null
      department: null
      department_code: null
      department_name: null
      started_at: null
      permit_changing_department_in_group: null
      permit_changing_department_in_organization: null
      permit_changing_started_at: null
      emailSelections: null
      submitActivate: false

    matchData = null
    matchEmailPattern = outerMatchEmailPattern
    emailSelections = []

    if !matchEmailPattern
      for emailPattern in @props.emailPatterns
        match = email.keyMatch emailPattern.email_regexp
        if match[0]
          matchData = match[0]
          matchEmailPattern = emailPattern
          break

    if matchEmailPattern
      @setState
        submitActivate: true

    if email?.match(/.+@.+\..+/) && !outerFound
      $.ajax
        url: "/user_emails/email_lookup.json?email=#{email}"
        dataType: 'json'
      .done @_lookupEmailDone
      .fail @_lookupEmailFail

    if !matchEmailPattern
      sp = email.split('@')
      for emailPattern in @props.emailPatterns
        match = sp[0].keyMatch emailPattern.email_account_regexp

        if match[0]
          if sp[1]
            if emailPattern.email_fixed_suffix.match(sp[1])
              emailSelections.push "#{sp[0]}#{emailPattern.email_fixed_suffix}"

            else
              domainGenerator = new RandExp(emailPattern.email_domain_regexp.toNativeRegExp())
              sampleDomain = domainGenerator.gen()
              testDomain = sp[1] + sampleDomain.slice(sp[1].length)
              domainMatch = testDomain.match(emailPattern.email_domain_regexp.toNativeRegExp())

              if domainMatch
                emailSelections.push "#{sp[0]}@#{domainMatch[0]}"
                emailSelections.push "#{sp[0]}@#{sp[1]}#{emailPattern.email_fixed_suffix}"

              else continue

          if !matchData || (Math.random() * 10 - 3 > (emailPattern.priority - matchEmailPattern.priority))
            matchData = match[0]
            matchEmailPattern = emailPattern

    if matchEmailPattern
      { corresponded_identity, organization_code, permit_changing_department_in_group, permit_changing_department_in_organization, permit_changing_started_at } = matchEmailPattern
      if outerMatchEmailPattern
        { uid, identity_detail, department_code, started_at } = matchEmailPattern
      else
        { uid, identity_detail, department_code, started_at } = matchData

      @_fetchDepartments(organization_code)

      setTimeout( =>
        @_fetchDepartments(organization_code)
      , 100)

      if identity_detail && matchEmailPattern.identity_detail_postparser
        n = identity_detail
        identity_detail = eval(matchEmailPattern.identity_detail_postparser)
      if department_code && matchEmailPattern.department_code_postparser
        n = department_code
        department_code = eval(matchEmailPattern.department_code_postparser)
      if started_at && matchEmailPattern.started_at_postparser
        n = started_at
        started_at = eval(matchEmailPattern.started_at_postparser)
      if uid && matchEmailPattern.uid_postparser
        n = uid
        uid = eval(matchEmailPattern.uid_postparser)

      organization_name = matchEmailPattern.organization.name

    else
      uid = corresponded_identity = identity_detail = organization_code = department_code = started_at = null
      permit_changing_department_in_group = false
      permit_changing_department_in_organization = false
      permit_changing_started_at = false
      organization_name = '?'

    @setState
      organization_name: organization_name
      uid: uid
      corresponded_identity: corresponded_identity
      identity_detail: identity_detail
      organization_code: organization_code
      department_code: department_code
      started_at: started_at
      permit_changing_department_in_group: permit_changing_department_in_group
      permit_changing_department_in_organization: permit_changing_department_in_organization
      permit_changing_started_at: permit_changing_started_at
      emailSelections: emailSelections

  render: ->

    permit_changing_department_in_group = @state.permit_changing_department_in_group
    permit_changing_department_in_organization = @state.permit_changing_department_in_organization
    permit_changing_started_at = @state.permit_changing_started_at

    @state.department = @state.departments[@state.department_code]
    baseGroup = @state.department?.group

    if (@state.permit_changing_department_in_group && @state.department) || @state.permit_changing_department_in_organization
      departments = @state.departments
      departments = $.extend({0: {code: '', name: '請選擇系所／部門'}}, departments) if @state.permit_changing_department_in_organization

      department_selector =
        `<select ref="deps"
          id="department-select"
          className="chosen-select"
          name="user_email[department_code]" >
          {Object.keys(departments).map(function(value, index) {
            d = departments[value];
            if (d.name && (baseGroup == d.group || permit_changing_department_in_organization))
              return (<option key={d.code}
                  value={d.code} >
                    {d.name}
                </option>);
          }.bind(this))}
        </select>`

    else
      department_selector = @state.department_name

    if @state.permit_changing_started_at
      current_year = (new Date().getFullYear())
      selections = []
      [current_year..(current_year - 20)].forEach (i) ->
        selections.push `<option key={i}
                                 value={i} >
                           {i} 年度入學
                         </option>`
      started_at_selector =
        `<select ref="started-at-select"
          id="started-at-select"
          className="chosen-select"
          name="user_email[started_at]" >
          {selections}
        </select>`
    else
      started_at_selector = "#{@state.started_at?.getFullYear() || '未知'} 年度入學"

    submitButtonClassName = classNames
      'btn btn--highlighted': true
      'disabled': !@state.submitActivate

    inputContainerClassName = classNames
      'form-group has-feedback': true
      'has-success': @state.submitActivate

    if @state.submitActivate
      # successIcon = `<span className="glyphicon glyphicon-ok form-control-feedback" aria-hidden="true"></span>`
    else
      successIcon = ''

    defaultValue = @props.email?.email

    if @state.email
      infoRow = `<div key="info-row" className="info-row">
        <div className="row clearfix">
          <div className="col-sm-6 col-md-4 organization hidden-sm">
            <div className="">
              <div className="caption">
                <p>{this.state.organization_code}</p>
                <p>{this.state.organization_name}</p>
              </div>
            </div>
          </div>
          <div className="col-sm-6 col-md-4 identity">
            <div className="">
              <div className="caption">
                <p key={this.state.i++}>{department_selector}</p>
                <p>{this.state.corresponded_identity}</p>
              </div>
            </div>
          </div>
          <div className="col-sm-6 col-md-4 identity-detail">
            <div className="">
              <div className="caption">
                <p className="hidden-sm">{this.state.uid}</p>
                <p className="visible-sm-block">{this.state.organization_name}</p>
                <p key={this.state.i++}>{started_at_selector}</p>
              </div>
            </div>
          </div>
        </div>
      </div>`
    else
      infoRow = null

    `<div>
      <div className={inputContainerClassName}>
        <div className="input-group">
          <span className="input-group-addon"><i className="glyphicon glyphicon-envelope"></i></span>
          <AutocompleteInput
            options={this.state.emailSelections}
            onChange={this.handleEmailChange}
            className="string email required form-control"
            id="user_email_email"
            name="user_email[email]"
            placeholder="請輸入您的學校 email"
            value={defaultValue}
            autofocus="true" />
        </div>
        {successIcon}
      </div>
      <ReactCSSTransitionGroup transitionName="info-row-fade-in">
        {infoRow}
      </ReactCSSTransitionGroup>
      <div>&nbsp;</div>
      <div className="action">
        <a className="btn btn--flat btn--gray" href="/">取消</a>
        &nbsp;&nbsp;
        <input className={submitButtonClassName} name="commit" type="submit" value="寄出驗證信" />
      </div>
    </div>`

  componentDidUpdate: ->
    document.getElementById('department-select')?.value = @state.department_code || ''
    document.getElementById('started-at-select')?.value = @state.started_at?.getFullYear() || (new Date().getFullYear())

    $('#department-select').select2()
    $('#started-at-select').select2()

    $('.organization .select2-choice').hover ->
      $('.organization .select2-choice')[0].focus()
    , ->
      $('.organization .select2-choice')[0].blur()

    $('.identity .select2-choice').hover ->
      $('.identity .select2-choice')[0].focus()
    , ->
      $('.identity .select2-choice')[0].blur()

    $('.identity-detail .select2-choice').hover ->
      $('.identity-detail .select2-choice')[0].focus()
    , ->
      $('.identity-detail .select2-choice')[0].blur()

    $('input[type="submit"]').hover ->
      $('input[type="submit"]')[0].focus()
    , ->
      $('input[type="submit"]')[0].blur()

    $("form#new_user_email").submit (e) =>
      if not @state.submitActivate
        e.preventDefault()

window.NewUserEmailBox = NewUserEmailBox
