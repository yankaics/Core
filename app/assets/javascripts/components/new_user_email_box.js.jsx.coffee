NewUserEmailBox = React.createClass
  mixins: [React.addons.LinkedStateMixin]
  propTypes:
    emailPatterns: React.PropTypes.array

  getInitialState: ->
    email: ''

  componentWillMount: ->
    for emailPattern in @props.emailPatterns
      emailPattern.email_fixed_suffix_regexp = emailPattern.email_regexp.match(/[@a-z0-9\.\\\$]+$/)[0]
      emailPattern.email_fixed_suffix = emailPattern.email_fixed_suffix_regexp.replace(/\\\./g, '.').replace(/[^@A-Za-z0-9\.]/g, '')
      emailPattern.email_regexp_without_fixed_suffix = emailPattern.email_regexp.replace(/[@a-z0-9\.\\\$]+$/, '')
      sp = emailPattern.email_regexp.split('@')
      emailPattern.email_account_regexp = sp[0]
      emailPattern.email_domain_regexp = sp[1]

  render: ->
    matchData = null
    matchEmailPattern = null
    submitActivate = false
    options = []

    for emailPattern in @props.emailPatterns
      match = @state.email.keyMatch emailPattern.email_regexp
      if match[0]
        matchData = match[0]
        matchEmailPattern = emailPattern
        submitActivate = true
        break

    if !matchData
      sp = @state.email.split('@')
      for emailPattern in @props.emailPatterns
        match = sp[0].keyMatch emailPattern.email_account_regexp

        if match[0]
          if sp[1]
            if emailPattern.email_fixed_suffix.match(sp[1])
              options.push "#{sp[0]}#{emailPattern.email_fixed_suffix}"

            else
              domainGenerator = new RandExp(emailPattern.email_domain_regexp.toNativeRegExp())
              sampleDomain = domainGenerator.gen()
              testDomain = sp[1] + sampleDomain.slice(sp[1].length)
              domainMatch = testDomain.match(emailPattern.email_domain_regexp.toNativeRegExp())

              if domainMatch
                options.push "#{sp[0]}@#{domainMatch[0]}"
                options.push "#{sp[0]}@#{sp[1]}#{emailPattern.email_fixed_suffix}"

              else continue

          if !matchData || (Math.random() * 10 - 3 > (emailPattern.priority - matchEmailPattern.priority))
            matchData = match[0]
            matchEmailPattern = emailPattern

    if matchData
      {corresponded_identity, organization_code, permit_changing_department_in_group, permit_changing_department_in_organization} = matchEmailPattern
      {uid, identity_detail, department_code, started_at} = matchData

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

    `<div>
      <div>{organization_name}</div>
      <div>{uid}</div>
      <div>{corresponded_identity}</div>
      <div>{identity_detail}</div>
      <div>{organization_code}</div>
      <div>{department_code}</div>
      <div>{started_at}</div>
      <div>{permit_changing_department_in_group}</div>
      <div>{permit_changing_department_in_organization}</div>
      <div>{this.state.email}</div>
      <AutocompleteInput options={options} valueLink={this.linkState('email')} className="string email required form-control" id="user_email_email" name="user_email[email]" autofocus="true" />
    </div>`

window.NewUserEmailBox = NewUserEmailBox
