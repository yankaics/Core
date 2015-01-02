ActiveAdmin.register User do
  menu priority: 10

  actions :all, except: [:create, :destroy]

  includes :data, :primary_identity

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  permit_params do
    params = []
    params.concat [:username, :scoped_organization_code] if current_admin.root?
    params
  end

  scope :all, :default => true
  scope :confirmed
  scope :unconfirmed
  scope :identified
  scope :unidentified

  index do
    selectable_column
    id_column
    column :name do |user|
      link_to user.name, admin_user_path(user)
    end
    column :email
    column :fbid do |user|
      link_to user.fbid, "https://facebook.com/#{user.fbid}", :target => "_blank" if user.fbid
    end
    column :confirmed_at
    column :sign_in_count
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
    column :fbtoken
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
    actions
  end

  index as: :grid, columns: 10, per_page: 500 do |user|
    div do
      link_to(image_tag(user.avatar_url), admin_user_path(user))
    end
    link_to(user.name, admin_user_path(user))
  end

  form do |f|
    f.inputs do
      f.input :admin
      f.input :name
      f.input :email
      f.input :fbid
      f.input :gender, :as => :select, :collection => options_for_select([['male', 'male'], ['female', 'female']], user.gender)
      f.input :identity, :as => :select, :collection => options_for_select([[t('bachelor'), 'bachelor'], [t('master'), 'master'], [t('doctor'), 'doctor'], [t('professor'), 'professor'], [t('staff'), 'staff'], [t('other'), 'other'], [t('guest'), 'guest']], user.identity)
      f.input :student_id
      f.input :admission_year
      f.input :admission_department_code, :as => :select, :collection => option_groups_from_collection_for_select(College.all, :departments, :name, :code, :name, user.admission_department_code)
      f.input :department_code, :as => :select, :collection => option_groups_from_collection_for_select(College.all, :departments, :name, :code, :name, user.department_code)
      f.input :mobile
      f.input :birthday
      f.input :address
      f.input :brief
    end
    f.actions
  end

end

# column :email
# column :name
# column :username
# column :fbid
# column :encrypted_password
# column :reset_password_token
# column :reset_password_sent_at
# column :remember_created_at
# column :sign_in_count
# column :current_sign_in_at
# column :last_sign_in_at
# column :current_sign_in_ip
# column :last_sign_in_ip
# column :confirmation_token
# column :confirmed_at
# column :confirmation_sent_at
# column :unconfirmed_email
# column :failed_attempts
# column :unlock_token
# column :locked_at
# column :primary_identity_id
# column :avatar_url
# column :cover_photo_url
# column :fbtoken
# column :gender
# column :birth_year
# column :birth_month
# column :birth_day
# column :url
# column :brief
# column :motto
# column :mobile
# column :unconfirmed_mobile
# column :mobile_confirmation_token
# column :mobile_confirmation_sent_at
# column :mobile_confirm_tries
