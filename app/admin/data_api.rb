ActiveAdmin.register DataAPI do
  menu priority: 51, parent: 'api'
  config.sort_order = :name_asc, :path_asc
  config.per_page = 100

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  controller do
    def scoped_collection
      super.includes(:organization)
    end

    def create
      @data_api = scoped_collection.new(data_api_params)
      @data_api.schema_from_array(data_api_params_schema_array)
      if @data_api.save
        redirect_to admin_data_api_path(@data_api)
      else
        render :new
      end
    end

    def update
      @data_api = scoped_collection.find(params[:id])
      @data_api.schema_from_array(data_api_params_schema_array) if data_api_params_schema_array.present?
      updated = @data_api.update(data_api_params)

      if updated
        redirect_to admin_data_api_path(@data_api)
      else
        render :edit
      end
    end

    def data_api_params
      p = [:name, :path]
      p.concat [:organization_code, :organization] if current_admin.root?
      params.require(:data_api).slice(*p).permit(p)
    end

    def data_api_params_schema_array
      return [] if params[:data_api].blank? || params[:data_api][:schema].blank?
      sp = params[:data_api][:schema]
      sp.map { |k, v| v }
    end
  end

  scope :all, :default => true, if: proc { current_admin.root? }
  scope :global, if: proc { current_admin.root? }
  scope :local, if: proc { current_admin.root? }

  permit_params do
    params = [:name, :path, :schema]
    params.concat [:organization_code, :organization] if current_admin.root?
    params
  end

  filter :name
  filter :path
  filter :created_at
  filter :updated_at

  sidebar "資料集 API" do
  end

  index do
    selectable_column
    column(:name) { |data_api| link_to data_api.name, admin_data_api_path(data_api) }
    column(:path)
    column(:organization) { |data_api| data_api.organization.blank? ? nil : link_to(data_api.organization_code, admin_organization_path(data_api.organization)) } if current_admin.root?
    id_column
    actions
  end

  show do
    attributes_table do
      row(:name)
      row(:path)
      row(:organization) if current_admin.root?
      row(:schema)
      row(:id)
      row(:created_at)
      row(:updated_at)
    end

    panel '資料綱要' do
      table(class: 'data_api_schema_table') do
        thead do
          th { '欄位名稱' }
          th { '欄位型態' }
        end
        tbody do
          data_api.schema.each do |name, column|
            tr do
              td { name }
              td do
                code { column[:type] }
              end
            end
          end
        end
      end
    end
  end

  form do |f|
    f.inputs "基本資訊" do
      f.input :name
      f.input :path
      f.input :organization_code, as: :select, collection: options_for_select(Organization.all_for_select, data_api.organization_code) if current_admin.root?
    end

    f.actions

    panel '資料綱要' do
      table(class: 'data_api_schema_table editable') do
        thead do
          th { '欄位名稱' }
          th { '欄位型態' }
          th { '增加/刪除' }
        end
        tbody do
          data_api.schema.each do |name, column|
            tr do
              td { text_field :name, class: :name, id: "data_api_schema_#{column[:uuid]}_name", name: "data_api[schema][#{column[:uuid]}][name]", value: name }
              td do
                code { column[:type] }
                hidden_field :name, id: "data_api_schema_#{column[:uuid]}_type", name: "data_api[schema][#{column[:uuid]}][type]", value: column[:type]
              end
              td do
                hidden_field :name, id: "data_api_schema_#{column[:uuid]}_name", name: "data_api[schema][#{column[:uuid]}][uuid]", value: column[:uuid]
                a(class: 'delete') { '-' }
              end
            end
          end

          tr(class: :new) do
            rand_uuid = SecureRandom.uuid
            td { text_field :name, class: :name, id: "data_api_schema_#{rand_uuid}_name", name: "data_api[schema][#{rand_uuid}][name]", value: '' }
            td do
              select_tag :name, options_for_select(DataAPI::COLUMN_TYPES), class: :type, id: "data_api_schema_#{rand_uuid}_type", name: "data_api[schema][#{rand_uuid}][type]"
            end
            td do
              hidden_field :name, id: "data_api_schema_#{rand_uuid}_name", name: "data_api[schema][#{rand_uuid}][uuid]"
              a(class: 'add') { '+' }
            end
          end
        end
      end
    end

    f.actions
  end
end
