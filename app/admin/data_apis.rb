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
      @data_api.assign_attributes(data_api_params)

      confirm_required = (@data_api.changes.keys & ['accessible', 'public', 'name', 'path', 'primary_key', 'default_order', 'database_url', 'maintain_schema', 'owned_by_user', 'owner_primary_key', 'owner_foreign_key']).present?
      confirm_required = true if @data_api.changes['schema'] && @data_api.changes['schema'][0] != @data_api.changes['schema'][1]
      confirm_required = true if @data_api.changes['has'] && @data_api.changes['has'][0] != @data_api.changes['has'][1]
      confirm_required = false if params[:confirm]

      if @data_api.valid?
        if confirm_required
          request.params['confirm_required'] = true
          render :edit
        else
          if @data_api.save
            redirect_to admin_data_api_path(@data_api)
          else
            render :edit
          end
        end
      else
        render :edit
      end
    end

    def data_api_params
      p = [:accessible, :public, :name, :path, :description, :notes, :primary_key, :default_order, :database_url, :maintain_schema, :owned_by_user, :owner_primary_key, :owner_foreign_key]
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
    column(:accessible)
    column(:public)
    column(:owned_by_user)
    column(:organization) { |data_api| data_api.organization.blank? ? nil : link_to(data_api.organization_code, admin_organization_path(data_api.organization)) } if current_admin.root?
    column(:maintain_schema)
    id_column
    column(:manage) { |data_api| link_to '管理資料集', admin_data_api_data_api_data_path(data_api_id: data_api.id) }
    actions
  end

  index as: :detailed_table do
    selectable_column
    column(:name) { |data_api| link_to data_api.name, admin_data_api_path(data_api) }
    column(:path)
    column(:accessible)
    column(:public)
    column(:description)
    column(:owned_by_user)
    column(:organization) { |data_api| data_api.organization.blank? ? nil : link_to(data_api.organization_code, admin_organization_path(data_api.organization)) } if current_admin.root?
    column(:maintain_schema)
    column(:primary_key)
    column(:default_order)
    column(:database_url) { |data_api| code { data_api.database_url } }
    column(:owner_primary_key)
    column(:owner_foreign_key)
    id_column
    column(:manage) { |data_api| link_to '管理資料集', admin_data_api_data_api_data_path(data_api_id: data_api.id) }
    actions
  end

  show do
    attributes_table do
      row(:accessible)
      row(:public)
      row(:name)
      row(:path)
      row(:organization) if current_admin.root?
      row(:description)
      row(:notes)
      row(:primary_key)
      row(:schema) { |data_api| pre { JSON.pretty_generate(data_api.schema) } }
      row(:default_order)
      row(:maintain_schema)
      row(:database_url) { |data_api| code { data_api.database_url } }
      row(:owned_by_user)
      row(:owner_primary_key)
      row(:owner_foreign_key)
      row(:id)
      row(:created_at)
      row(:updated_at)
    end

    panel '資料綱要' do
      table(class: 'data_api_schema_table') do
        thead do
          th { '欄位名稱' }
          th { '欄位型別' }
        end
        tbody do
          data_api.schema.each do |name, column|
            tr do
              td { name }
              td do
                code { column['type'] }
              end
            end
          end
        end
      end
    end

    panel '資料集' do
      para do
        link_to '管理資料集', admin_data_api_data_api_data_path(data_api_id: data_api.id)
      end
    end
  end

  form do |f|
    if request.params['confirm_required']
      div(class: 'edit_data_api_confirm') do
        panel '確認更動' do
          h2 '確認？'
          para "您即將更動 #{data_api.name} 的設定。有些改變是不可復原的，例如改動 schema 所造成的資料遺失，隨意更改路徑或資料關聯也有可能造成已串接的應用程式損壞。請再三確認以下變更沒有問題："
          br
          data_api.changes.each_pair do |k, v|
            bef = v[0]
            aft = v[1]
            bef = JSON.pretty_generate(bef) if bef.is_a?(Hash)
            aft = JSON.pretty_generate(aft) if aft.is_a?(Hash)
            next if bef == aft
            h3 k
            para '從原本的：'
            pre bef
            para '改變成：'
            pre aft
          end
          hidden_field :confirm, name: 'confirm', value: 'true'
          style '.edit_data_api_form { display: none }'
          f.actions
        end
      end
    end

    if data_api.errors.present?
      div(class: 'errors') do
        panel '錯誤' do
          para "您對 #{data_api.name} 的設定有以下錯誤："
          br
          ul do
            data_api.errors.each do |k, v|
              li "#{k}: #{v}"
            end
          end
        end
      end
    end

    div(class: 'edit_data_api_form') do
      f.inputs "基本資訊" do
        f.input :accessible
        f.input :public
        f.input :name
        f.input :path
        f.input :organization_code, as: :select, collection: options_for_select(Organization.all_for_select, data_api.organization_code) if current_admin.root?
        f.input :description
        f.input :notes

        f.input :primary_key, hint: "必須是存在的欄位名稱"
        f.input :default_order, hint: "必須使用存在的欄位名稱"
      end

      f.inputs "資源擁有者" do
        f.input :owned_by_user
        f.input :owner_primary_key, as: :select, collection: options_for_select(DataAPI::OWNER_PRIMARY_KEYS, data_api.owner_primary_key)
        f.input :owner_foreign_key, hint: "必須是存在的欄位名稱"
      end

      panel '資料綱要' do
        table(class: 'data_api_schema_table editable') do
          thead do
            th { '欄位名稱' }
            th { '欄位型別' }
            th { '增加/刪除' }
          end
          tbody do
            data_api.schema.each do |name, column|
              tr do
                td { text_field :name, class: :name, id: "data_api_schema_#{column['uuid']}_name", name: "data_api[schema][#{column['uuid']}][name]", value: name }
                td do
                  code { column['type'] }
                  hidden_field :name, id: "data_api_schema_#{column['uuid']}_type", name: "data_api[schema][#{column['uuid']}][type]", value: column['type']
                end
                td do
                  hidden_field :name, id: "data_api_schema_#{column['uuid']}_name", name: "data_api[schema][#{column['uuid']}][uuid]", value: column['uuid']
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

      f.inputs "進階資料庫連線資訊" do
        f.input :database_url, hint: "如資料存放在外部資料庫，可在此欄填寫其資料庫網址，支援 PostgreSQL ('postgresql://USER:PASSWORD@HOST:PORT/NAME') 以及 MySQL ('mysql://USER:PASSWORD@HOST:PORT/NAME')，留空表示使用系統的資料庫"
        f.input :maintain_schema, hint: "若取消自動維護資料表，則需要手動確保資料庫綱要與設定一致，否則會在存取資料時發生錯誤，關閉此功能而又開啟、或搬遷到新資料庫，也需手動設定資料表"
      end

      f.actions
    end
  end
end
