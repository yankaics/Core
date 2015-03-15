ActiveAdmin.register User do
  menu priority: 10
  config.per_page = 100

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  controller do
    def scoped_collection
      super.includes(:data, primary_identity: [:organization, :department])
    end
  end

  actions :all, except: [:new, :create, :destroy]

  includes :data, :primary_identity

  permit_params do
    params = [:name, :avatar_url, :cover_photo_url, :gender, :birth_date, :birth_year, :birth_month, :birth_day, :url, :brief, :motto]
    params.concat [:email, :username, :fbid, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at, :primary_identity_id, :fbtoken, :mobile, :unconfirmed_mobile, :mobile_confirmation_token, :mobile_confirmation_sent_at, :mobile_confirm_tries] if current_admin.root?
    params
  end

  scope :all, :default => true
  scope :confirmed
  scope :unconfirmed
  scope :identified
  scope :unidentified

  filter :id
  filter :email
  filter :name
  filter :username
  filter :fbid
  filter :created_at
  filter :confirmed_at
  filter :updated_at
  filter :last_sign_in_at
  filter :last_sign_in_ip
  filter :locked_at
  filter :unconfirmed_email
  filter :mobile
  filter :unconfirmed_mobile

  index do
    selectable_column
    id_column
    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :fbid do |user|
      link_to truncate(user.fbid, length: 8), "https://facebook.com/#{user.fbid}", :target => "_blank" if user.fbid
    end
    column :identity do |user|
      link_to "#{truncate(user.organization_short_name, length: 5)} #{truncate(user.department_short_name, length: 5)} #{UserIdentity.human_enum_value(:identity, user.identity)}", admin_user_identity_path(user.primary_identity) if user.primary_identity
    end
    column :confirmed_at
    column :sign_in_count
    column :testing do |user|
      link_to '登入', testing_user_sessions_path(id: user.id), method: :post, class: :login, data: { confirm: "確定要用 #{user.name} 的帳號登入嗎？" }
    end if current_admin.root?
    actions
  end

  index as: :detailed_table do
    selectable_column
    id_column
    column :confirmed_at
    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :username
    column :fbid do |user|
      link_to user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank"
    end
    column :fbid
    column :encrypted_password
    column :reset_password_token
    column :reset_password_sent_at
    column :remember_created_at
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :confirmation_token
    column :confirmation_sent_at
    column :unconfirmed_email
    column :failed_attempts
    column :unlock_token
    column :locked_at
    column :primary_identity_id
    column :avatar_url
    column :cover_photo_url
    column :fbtoken if current_admin.root?
    column :gender
    column :birth_year
    column :birth_month
    column :birth_day
    column :url
    column :brief
    column :motto
    column :mobile
    column :unconfirmed_mobile
    column :mobile_confirmation_token
    column :mobile_confirmation_sent_at
    column :mobile_confirm_tries
    column :testing do |user|
      link_to '登入', testing_user_sessions_path(id: user.id), method: :post, class: :login, data: { confirm: "確定要用 #{user.name} 的帳號登入嗎？" }
    end if current_admin.root?
    actions
  end

  index as: :grid, columns: 10, per_page: 500 do |user|
    div do
      link_to(image_tag(user.avatar_url), admin_user_path(user))
    end
    link_to(user.name, admin_user_path(user))
  end

  show do
    attributes_table do
      row(:id)
      row(:email)
      row(:username)
      row(:name)

      row(:primary_identity)
      row(:identity)
      row(:organization)
      row(:department)
      row(:uid)

      row(:avatar_url)
      row(:cover_photo_url)

      row(:gender)
      row(:birth_date)
      row(:url)
      row(:brief)
      row(:motto)
      row(:mobile)

      row(:fbid)
      row(:fbtoken)

      row(:sign_in_count)
      row(:current_sign_in_at)
      row(:last_sign_in_at)
      row(:current_sign_in_ip)
      row(:last_sign_in_ip)

      row(:confirmation_sent_at)
      row(:confirmed_at)
      row(:created_at)
      row(:updated_at)
    end

    panel '操作' do
      para do
        link_to '使用此帳號登入', testing_user_sessions_path(id: user.id), method: :post, class: :login, data: { confirm: "確定要用 #{user.name} 的帳號登入嗎？" }
      end
    end if current_admin.root?

    panel '使用者 Email' do
      table_for user.all_emails.includes(:associated_user_identity) do
        column(:id)
        column(:email)
        bool_column(:confirmed?)
        column(:associated_user_identity)
        column(:created_at)
        column(:confirmation_sent_at)
        column(:confirmed_at)
      end
    end if current_admin.root?

    panel '使用者身份' do
      table_for user.identities.includes(:email_pattern, :organization, :department, :original_department) do
        column(:id) { |identity| link_to identity.id, admin_user_identity_path(identity) }
        column(:email)
        bool_column(:primary?)
        bool_column(:generated?)
        column(:email_pattern)
        column(:identity)
        column(:name)
        column(:organization)
        column(:department)
        column(:original_department)
        column(:created_at)
      end
    end if current_admin.root?

    panel '細項' do
      attributes_table_for user do
        row(:encrypted_password)
        row(:reset_password_sent_at)
        row(:reset_password_token)

        row(:unconfirmed_email)
        row(:confirmation_sent_at)
        row(:confirmation_token)
        row(:confirmed_at)

        row(:mobile)
        row(:unconfirmed_mobile)
        row(:mobile_confirmation_token)
        row(:mobile_confirmation_sent_at)
        row(:mobile_confirm_tries)

        row(:failed_attempts)
        row(:locked_at)
        row(:unlock_token)

        row(:remember_created_at)

        row(:devices)
      end
    end if current_admin.root?
  end

  form do |f|
    f.inputs do
      f.input :email if current_admin.root?
      f.input :name
      f.input :username if current_admin.root?
      f.input :fbid if current_admin.root?
      f.input :encrypted_password if current_admin.root?
      f.input :reset_password_token if current_admin.root?
      f.input :reset_password_sent_at if current_admin.root?
      f.input :remember_created_at if current_admin.root?
      f.input :sign_in_count if current_admin.root?
      f.input :current_sign_in_at if current_admin.root?
      f.input :last_sign_in_at if current_admin.root?
      f.input :current_sign_in_ip if current_admin.root?
      f.input :last_sign_in_ip if current_admin.root?
      f.input :confirmation_token if current_admin.root?
      f.input :confirmed_at if current_admin.root?
      f.input :confirmation_sent_at if current_admin.root?
      f.input :unconfirmed_email if current_admin.root?
      f.input :failed_attempts if current_admin.root?
      f.input :unlock_token if current_admin.root?
      f.input :locked_at if current_admin.root?
      f.input :primary_identity_id if current_admin.root?
      # f.input :avatar_url
      # f.input :cover_photo_url
      f.input :fbtoken if current_admin.root?
      f.input :gender, as: :select, collection: options_for_select(UserData.enum_for_select(:gender), user.gender)
      f.input :birth_date, as: :datepicker
      f.input :url
      f.input :brief
      f.input :motto
      f.input :mobile if current_admin.root?
      f.input :unconfirmed_mobile if current_admin.root?
      f.input :mobile_confirmation_token if current_admin.root?
      f.input :mobile_confirmation_sent_at if current_admin.root?
      f.input :mobile_confirm_tries if current_admin.root?
    end
    f.actions
  end
end
