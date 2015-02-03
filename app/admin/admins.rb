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
    column(:type) { |admin| admin.root? ? status_tag(:ROOT, :class => 'yes') : status_tag(:SCOPED) }
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
    para '若有指定系統管理員的「所屬組織」，則此管理員的權限會被限制在該組織內。'
    dl do
      dt 'Root Admin'
      dd '無「所屬組織」的系統管理員，擁有最大權限，可以管理所有使用者、組織、應用程式、系統設定以及其他系統管理員帳號。'
      dt 'Scoped Admin'
      dd '設有「所屬組織」的系統管理員，只能管理自身所屬組織的資料，並無權管理應用程式、系統設定以及其他系統管理員帳號。'
    end
  end
end
