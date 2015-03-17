ActiveAdmin.register DataAPI::Data, namespace: :admin do
  belongs_to :data_api
  navigation_menu :default
  menu priority: 60, parent: 'api', if: proc { params[:controller] == "admin/data_api_data" }
  config.per_page = 100

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  controller do
    before_action :set_model

    def scoped_collection
      super
    end

    def set_model
      DataAPI::Data.model = scoped_collection.model
      active_admin_namespace.permitted_params += [:data_api_id]
    end
  end

  permit_params do
    DataAPI::Data.column_names
  end

  sidebar "資料集 API" do
  end

  active_admin_import :validate => true,
                      :template => 'admin/data_api_import'
end
