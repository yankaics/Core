ActiveAdmin.register Department do
  menu priority: 111, parent: "組織資料"
  config.sort_order = :organization_code_asc, :code_asc

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  scope :all, :default => true
  scope :root
  scope :not_root

  permit_params do
    params = [:code, :short_name, :name, :parent, :parent_code, :group]
    params.concat [:organization_code, :organization] if current_admin.root?
    params
  end

  filter :organization, if: proc { current_admin.root? }
  filter :code_cont
  filter :name
  filter :short_name
  # filter :parent, if: proc { current_admin.root? }
  filter :group
  filter :created_at
  filter :updated_at

  config.per_page = 100

  sidebar "部門資料" do
    para '組織下的各部門資料，可指定一個部門的「父部門」來製作巢狀結構。'
    dl do
      dt '代碼'
      dd '由英數組成的識別碼，在組織內必須唯一。'
      dt '全名'
      dd '部門的完整名稱。'
      dt '簡稱'
      dd '部門的簡略名稱。'
      dt '類型代號'
      dd '部門的類型代號，由一至三個任意英數字元組成。可配合「使用者身份」或「電子郵件識別模型」的「允許切換到同類型的部門」設定使用。'
      dt '父部門'
      dd '可指定一個部門的「父部門」來製作巢狀結構。'
    end
  end

  index do
    selectable_column
    column(:organization) { |department| link_to department.organization_code, admin_organization_path(department.organization) } if current_admin.root?
    column(:parent) { |department| link_to department.parent.name, admin_department_path(department.parent) if department.parent }
    column(:code) { |department| link_to department.code, admin_department_path(department) }
    column(:short_name) { |department| link_to department.short_name, admin_department_path(department) }
    column(:name) { |department| link_to department.name, admin_department_path(department) }
    column(:group)
    id_column
    actions
  end

  form do |f|
    f.inputs do
      f.input :organization_code, as: :select, collection: options_for_select(Organization.all.map { |o| [o.name, o.code] }, department.organization_code) if current_admin.root?
      f.input :code
      f.input :name
      f.input :short_name
      f.input :parent_code if current_admin.root?
      f.input :parent, as: :select, collection: options_for_select(current_admin.organization.departments.all.map { |d| [d.name, d.code] }, department.parent_code) if !current_admin.root?
      f.input :group
    end
    f.actions
  end
end
