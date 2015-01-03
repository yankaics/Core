ActiveAdmin.register Admin do
  menu priority: 1000, label: "系統管理員帳號", if: proc { current_admin.root? }

  scope_to(if: proc { current_admin.scoped? }) { current_admin }

  permit_params do
    params = [:email, :password, :password_confirmation]
    params.concat [:username, :scoped_organization_code] if current_admin.root?
    params
  end

  index do
    selectable_column
    id_column
    column :username
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :scoped_organization_code
    actions
  end

  filter :username
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :username if current_admin.root?
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :scoped_organization_code, as: :select, collection: options_for_select(Organization.all.map { |u| [u.name, u.code] }, admin.scoped_organization_code) if current_admin.root?
    end
    f.actions
  end

  sidebar "系統管理員權限" do
    p '若有指定系統管理員的「所屬組織」，則此管理員的權限會被限制在該組織內。'
  end
end
