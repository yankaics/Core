class Users::EmailsController < ApplicationController
  before_action :random_body_background_image, only: [:new]
  before_action :authenticate_user!, except: [:confirm]
  after_action :refresh_signon_status_token, only: [:confirm, :destroy]
  after_action :refresh_site_identity_token, only: [:confirm, :destroy]

  def index
    @emails = current_user.all_emails.includes(associated_user_identity: [:organization])
    @confirmed_emails = @emails.confirmed
    @unconfirmed_emails = @emails.unconfirmed
  end

  def new
    @email = current_user.emails.build
    @email_patterns = EmailPattern.includes(:organization).all.serialize_it.as_json
    @email_patterns.each { |ep| ep[:corresponded_identity] = I18n.t(ep[:corresponded_identity], scope: :'user.identity') }

    # if a new user
    if current_user.primary_identity_id.blank? && current_user.created_at > 2.hours.ago
      # find if there is a predefined identity with this email
      # or matching email patterns
      if UserIdentity.find_by(user_id: nil, email: current_user.email) ||
         EmailPattern.identify(current_user.email)
        @email.email = current_user.email
      end
    end
  end

  def create
    @email = current_user.emails.build(user_email_params)

    ActiveRecord::Base.transaction do
      if @email.save
        if @email.email == current_user.email || @email.can_skip_confirmation?
          @email.confirm!
          flash[:notice] = "Email 經驗證，已開通對應身份！"
        else
          @email.send_confirmation_instructions
          flash[:notice] = "驗証信已送出！"
        end
      else
        flash[:error] = "無效的 Email，或該 Email 已經被使用。"
      end
    end

    redirect_to :action => :index
  end

  def update
    @email = current_user.unconfirmed_emails.find(params[:id])
    @email.resend_confirmation_instructions

    redirect_to :action => :index
  end

  def confirm
    @email = UserEmail.find_and_confirm(params[:confirmation_token])

    if @email.present?
      render html: <<-EOF.strip_heredoc.html_safe
        <style>
          body {
            background: rgba(246, 155, 134, 1);
            font-family: 'Open Sans', sans-serif;
            color: #222;
          }

          a {
            color: currentColor;
            text-decoration: none;
          }

          p {
            font-size: 13px;
          }

          a:hover .card-outmore {
            background: #2C3E50;
            color: #fff;
          }

          a:hover .thecard {
            box-shadow: 0 10px 50px rgba(0,0,0,.6);
          }

          .thecard {
            width: 300px;
            margin: 5% auto;
            box-shadow: 0 1px 30px rgba(0,0,0,.4);
            display: block;
            background-color: #fff;
            border-radius: 4px;
            transition: 400ms ease;
          }

          .card-img {
            height: 225px;
          }

          .card-img img {
            width:100%;
            border-radius: 4px 4px 0px 0px;
          }

          .card-caption {
            position: relative;
            background: #ffffff;
            padding: 15px 25px 15px 25px;
            border-radius: 0px 0px 4px 4px;
          }

          .card-outmore {
            padding: 10px 25px 12px 25px;
            border-radius: 0px 0px 4px 4px;
            border-top: 1px solid #e0e0e0;
            background: #efefef;
            color: #222;
            display: inline-table;
            width: 250px;
            transition: 400ms ease;
          }

          .card-outmore h5 {
            float: left;
          }

          h1 {
            font-size: 22px;
          }

          h5 {
            margin:0;
          }
        </style>

        <a href="https://colorgy.io/">
          <div class="thecard">
            <div class="card-caption">
              <h1>Email 驗證已完成</h1>
              <p>您已完成學校身份認證，可以繼續使用囉！</p>
            </div>
            <div class="card-outmore">
              <h5>到 colorgy.io 首頁 →</h5>
            </div>
          </div>
        </a>
      EOF
    else
      render html: <<-EOF.strip_heredoc.html_safe
        <style>
          body {
            background: rgba(246, 155, 134, 1);
            font-family: 'Open Sans', sans-serif;
            color: #222;
          }

          a {
            color: currentColor;
            text-decoration: none;
          }

          p {
            font-size: 13px;
          }

          a:hover .card-outmore {
            background: #2C3E50;
            color: #fff;
          }

          a:hover .thecard {
            box-shadow: 0 10px 50px rgba(0,0,0,.6);
          }

          .thecard {
            width: 300px;
            margin: 5% auto;
            box-shadow: 0 1px 30px rgba(0,0,0,.4);
            display: block;
            background-color: #fff;
            border-radius: 4px;
            transition: 400ms ease;
          }

          .card-img {
            height: 225px;
          }

          .card-img img {
            width:100%;
            border-radius: 4px 4px 0px 0px;
          }

          .card-caption {
            position: relative;
            background: #ffffff;
            padding: 15px 25px 15px 25px;
            border-radius: 0px 0px 4px 4px;
          }

          .card-outmore {
            padding: 10px 25px 12px 25px;
            border-radius: 0px 0px 4px 4px;
            border-top: 1px solid #e0e0e0;
            background: #efefef;
            color: #222;
            display: inline-table;
            width: 250px;
            transition: 400ms ease;
          }

          .card-outmore h5 {
            float: left;
          }

          h1 {
            font-size: 22px;
          }

          h5 {
            margin:0;
          }
        </style>

        <a href="https://colorgy.io/">
          <div class="thecard">
            <div class="card-caption">
              <h1>啊喔，您使用的驗證連結有誤</h1>
              <p>可能您的驗證連結已經過期，請嘗試重新再申請驗證一次！</p>
            </div>
            <div class="card-outmore">
              <h5>到 colorgy.io 首頁 →</h5>
            </div>
          </div>
        </a>
      EOF
    end
  end

  def destroy
    current_user.all_emails.find(params[:id]).destroy

    redirect_to :action => :index
  end

  def query_departments
    @departments = Department.where(organization_code: params[:organization_code])
                   .select(:name, :short_name, :parent_code, :code, :group)
    @departments = Hash[@departments.map { |obj| [obj.code, obj] }]

    @departments[:organization_code] = params[:organization_code]

    respond_to do |format|
      format.json { render json: @departments }
    end
  end

  def email_lookup
    @user_identity = UserIdentity.includes(:organization)
                     .select(:id, :organization_code, :department_code, :identity, :identity_detail, :email, :uid, :permit_changing_department_in_group, :permit_changing_department_in_organization)
                     .find_by(email: params[:email], user_id: nil)

    if @user_identity
      @data = @user_identity.serializable_hash
      @data[:organization] = @user_identity.organization.slice(:name, :short_name, :code)
      @data[:identity] = I18n.t(@user_identity.identity, scope: :'user.identity')
      @data[:corresponded_identity] = @data[:identity]
    else
      @data = nil
    end

    respond_to do |format|
      format.json { render json: @data }
    end
  end

  private

  def user_email_params
    params.require(:user_email).permit(:email, :department_code, :started_at)
  end
end
