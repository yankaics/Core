ActiveAdmin.register UserIdentity do
  menu priority: 113, parent: "組織資料"
  config.sort_order = :organization_code_asc, :uid_asc

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  scope :all
  scope :generated
  scope :predefined, :default => true
  scope :linked
  scope :unlinked

  permit_params do
    params = [:name, :email, :identity, :uid, :department, :department_code, :original_department, :original_department_code, :permit_changing_department_in_group, :permit_changing_department_in_organization]
    params.concat [:organization_code, :organization] if current_admin.root?
    params
  end

  filter :organization, if: proc { current_admin.root? }
  filter :department
  filter :original_department
  filter :name
  filter :email
  filter :identity
  filter :uid
  filter :permit_changing_department_in_group
  filter :permit_changing_department_in_organization
  filter :created_at
  filter :updated_at

  sidebar "使用者身份" do
    para '使用者經由「使用者身份」關聯至組織與組織內的部門。一位使用者可擁有多重身份，並屬於多個組織。「使用者身份」可能由「電子郵件識別模型」自動解析 email 產生；或是手動輸入，當未來有使用者認證相同的 email 時，再連結到該使用者。'
    dl do
      dt '對應使用者'
      dd '目前擁有此身份的使用者。'
      dt '對應電子郵件識別模型'
      dd '若身份係由「電子郵件識別模型」產生，生成此身份的「電子郵件識別模型」。'
      dt '對應電子郵件'
      dd '開通此身份所需要認證的電子郵件。'
      dt '使用者名稱'
      dd '擁有此身份的使用者，預設的名稱。'
      dt '身份'
      dd '此身份的身份類型。'
      dt '所屬部門'
      dd '此身份的所屬部門。'
      dt '原所屬部門'
      dd '此身份的原所屬部門。'
      dt '可切換同型部門'
      dd '若設為「是」，則使用者可以更改此身份到同組織、同種類的任意部門。'
      dt '可切換部門'
      dd '若設為「是」，則使用者可以更改此身份到同組織的任意部門。'
    end
  end

  config.per_page = 100

  index do
    selectable_column
    column(:organization) { |user_identity| link_to user_identity.organization_code, admin_organization_path(user_identity.organization) } if current_admin.root?
    column(:department) { |user_identity| link_to user_identity.department.name, admin_department_path(user_identity.department) if user_identity.department }
    column(:original_department) { |user_identity| link_to user_identity.original_department.name, admin_department_path(user_identity.original_department) if user_identity.original_department }
    column(:user) { |user_identity| link_to user_identity.user.name, admin_user_path(user_identity.user) if user_identity.user }
    column(:name) { |user_identity| link_to user_identity.name, admin_user_identity_path(user_identity) if user_identity.name }
    column(:email) { |user_identity| link_to user_identity.email, admin_user_identity_path(user_identity) }
    column(:identity)
    column(:uid)
    column(:permit_changing_department_in_group)
    column(:permit_changing_department_in_organization)
    id_column
    actions
  end

  form do |f|
    f.inputs do
      f.input :organization_code, as: :select, collection: options_for_select(Organization.all.map { |u| [u.name, u.code] }, user_identity.organization_code) if current_admin.root?
      f.input :department_code if current_admin.root?
      f.input :original_department_code if current_admin.root?
      f.input :department, as: :select, collection: options_for_select(current_admin.organization.departments.all.map { |d| [d.name, d.code] }, user_identity.department_code) if !current_admin.root?
      f.input :original_department, as: :select, collection: options_for_select(current_admin.organization.departments.all.map { |d| [d.name, d.code] }, user_identity.original_department_code) if !current_admin.root?
      f.input :name
      f.input :email
      f.input :identity, as: :select, collection: options_for_select(UserIdentity::IDENTITES.map { |k, v| [k, k] }, user_identity.identity)
      f.input :uid
      f.input :permit_changing_department_in_group
      f.input :permit_changing_department_in_organization
    end
    f.actions
  end
end
