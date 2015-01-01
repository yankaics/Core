ActiveAdmin.register Department do
  menu priority: 113, parent: "組織資料"
  config.sort_order = :organization_code_asc

  permit_params :organization_code, :college_code, :code, :short_name, :name, :parent, :parent_code, :group

  filter :organization
  filter :code_cont
  filter :name
  filter :short_name
  filter :parent
  filter :group
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column(:organization) { |department| link_to department.organization_code, admin_organization_path(department.organization) }
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
      f.input :organization_code, as: :select, collection: options_for_select(Organization.all.map { |u| [u.name, u.code] }, department.organization_code)
      f.input :code
      f.input :name
      f.input :short_name
      f.input :parent_code
      f.input :group
    end
    f.actions
  end
end
