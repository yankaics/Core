NewUserEmailBox = React.createClass
  mixins: [React.addons.LinkedStateMixin]
  propTypes:
    emailPatterns: React.PropTypes.array

  getInitialState: ->
    email: ''
    departments: {}
    cached_departments: {}
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
    submitActivate: false

  componentWillMount: ->
    for emailPattern in @props.emailPatterns
      emailPattern.email_fixed_suffix_regexp = emailPattern.email_regexp.match(/[@a-z0-9\.\\\$]+$/)[0]
      emailPattern.email_fixed_suffix = emailPattern.email_fixed_suffix_regexp.replace(/\\\./g, '.').replace(/[^@A-Za-z0-9\.]/g, '')
      emailPattern.email_regexp_without_fixed_suffix = emailPattern.email_regexp.replace(/[@a-z0-9\.\\\$]+$/, '')
      sp = emailPattern.email_regexp.split('@')
      emailPattern.email_account_regexp = sp[0]
      emailPattern.email_domain_regexp = sp[1]

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

  _UpdateDepartments: ->
    @setState
      department: @state.departments[@state.department_code]
      department_name: @state.departments[@state.department_code]?['name']

  handleEmailChange: (email) ->
    @setState
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
      emailSelections: null
      submitActivate: false

    matchData = null
    matchEmailPattern = null
    emailSelections = []

    for emailPattern in @props.emailPatterns
      match = email.keyMatch emailPattern.email_regexp
      if match[0]
        matchData = match[0]
        matchEmailPattern = emailPattern
        @setState
          submitActivate: true
        break

    if !matchData
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

    if matchData
      {corresponded_identity, organization_code, permit_changing_department_in_group, permit_changing_department_in_organization} = matchEmailPattern
      {uid, identity_detail, department_code, started_at} = matchData

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
      emailSelections: emailSelections

  render: ->

    permit_changing_department_in_group = @state.permit_changing_department_in_group
    permit_changing_department_in_organization = @state.permit_changing_department_in_organization

    @state.department = @state.departments[@state.department_code]
    baseGroup = @state.department?.group
    if (@state.permit_changing_department_in_group || @state.permit_changing_department_in_organization) && @state.department

      department_selector =
        `<select ref="deps"
          id="department-select"
          className="chosen-select"
          name="user_email[department_code]" >
          {Object.keys(this.state.departments).map(function(value, index) {
            d = this.state.departments[value];
            if (baseGroup == d.group || permit_changing_department_in_organization)
              return (<option
                  value={d.code} >
                    {d.name}
                </option>);
          }.bind(this))}
        </select>`

    else
      department_selector = this.state.department_name

    submitButtonClassName = React.addons.classSet(
      'btn btn-default',
      (if @state.submitActivate then '' else 'disabled'))

    `<div>
      <div>{this.state.organization_name}</div>
      <div>{this.state.uid}</div>
      <div>{this.state.corresponded_identity}</div>
      <div>{this.state.identity_detail}</div>
      <div>{this.state.organization_code}</div>
      <div>{this.state.department_code}</div>
      <div>{department_selector}</div>
      <div>{this.state.started_at}</div>
      <div>{this.state.permit_changing_department_in_group}</div>
      <div>{this.state.permit_changing_department_in_organization}</div>
      <div>{this.state.email}</div>
      <AutocompleteInput
        options={this.state.emailSelections}
        onChange={this.handleEmailChange}
        className="string email required form-control"
        id="user_email_email"
        name="user_email[email]"
        autofocus="true" />
      <input className={submitButtonClassName} name="commit" type="submit" value="驗證" />
    </div>`

  componentDidUpdate: ->
    document.getElementById('department-select')?.value = @state.department_code
    $('#department-select').chosen()
    $('#department-select').trigger('chosen:updated')
    $('.chosen-container + .chosen-container').remove()
    $('.chosen-container').hover ->
      $('#department-select').focus()
    $("form#new_user_email").submit (e) =>
      if not @state.submitActivate
        e.preventDefault()

window.NewUserEmailBox = NewUserEmailBox
