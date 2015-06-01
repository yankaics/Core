ActiveAdmin.register DataAPI do
  menu priority: 51, parent: 'api'
  config.sort_order = :name_asc, :path_asc
  config.per_page = 100

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  controller do
    def scoped_collection
      super.includes(:organization)
    end

    def new
      if params[:template_data_api_id]
        template = scoped_collection.find_by(id: params[:template_data_api_id])
        if template.present?
          template = template.dup
          template.management_api_key = nil
          template.initialize_management_api_key
          @data_api = template
        end
      end

      super
    end

    def create
      @data_api = scoped_collection.new(data_api_params)
      @data_api.schema.load_from_array(data_api_params_schema_array)
      if @data_api.save
        redirect_to admin_data_api_path(@data_api)
      else
        render :new
      end
    end

    def update
      @data_api = scoped_collection.find(params[:id])
      @data_api.schema.load_from_array(data_api_params_schema_array) if data_api_params_schema_array.present?
      @data_api.assign_attributes(data_api_params)
      @data_api.nilify_blanks

      confirm_required = (@data_api.changes.keys & ['accessible', 'public', 'name', 'table_name', 'path', 'primary_key', 'default_order', 'database_url', 'maintain_schema', 'owned_by_user', 'owner_primary_key', 'owner_foreign_key', 'owner_writable']).present?
      previous_version = DataAPI.find(@data_api.id)
      confirm_required = true if @data_api.schema != previous_version.schema
      confirm_required = true if @data_api.has != previous_version.has
      confirm_required = false if params[:confirm]

      if @data_api.valid?
        if confirm_required
          request.params['confirm_required'] = true
          render :edit
        else
          begin
            if @data_api.save
              redirect_to admin_data_api_path(@data_api)
            else
              render :edit
            end
          rescue Exception => e
            @data_api.exception = e
            render :edit
          end
        end
      else
        render :edit
      end
    end

    def data_api_params
      p = [:accessible, :public, :name, :table_name, :path, :management_api_key, :description, :notes, :primary_key, :default_order, :database_url, :maintain_schema, :owned_by_user, :owner_primary_key, :owner_foreign_key, :owner_writable]
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
  filter :table_name
  filter :path
  filter :accessible
  filter :public
  filter :owned_by_user
  filter :owner_writable
  filter :created_at
  filter :updated_at

  sidebar "資料集 API" do
    para '以資料庫中資料為基礎提供的 API 資源。預設將資料存放在系統的「資料集」資料庫中，並由系統自動維護資料表；亦可設定連線進其他資料庫來取得資料製作成 API。'
    para '只要資料集裡有欄位存放的是使用者的 <code>id</code>、<code>uuid</code>、<code>email</code> 或 <code>uid</code>，就能設定資料與使用者的關聯，進而開啟 OAuth 認證來取得個別使用者資料的功能。'.html_safe
    para '相關名詞解釋如下：'
    dl do
      dt '開放使用'
      dd '是否開放此 API 的使用？'
      dt '公開'
      dd '是否讓此 API 能夠透過公開路徑存取？若開啟，則任何人可由 <code>/api/&lt;API_存取路徑&gt;</code> 存取此 API。注意這不會影響經過認證的個別使用者所屬資料存取 (<code>/api/v1/me/&lt;API_存取路徑&gt;</code>)。'.html_safe
      dt '名稱'
      dd '此 API 資源的識別名稱，僅可使用小寫字母、數字與底線。'
      dt '資料表名稱'
      dd '此資料集在資料庫中的資料表名稱。'
      dt 'API 存取路徑'
      dd '此 API 的存取路徑。將影響公開存取 (<code>/api/&lt;API_存取路徑&gt;</code>) 與個別使用者的私有存取 (<code>/api/v1/me/&lt;API_存取路徑&gt;</code>)。'.html_safe
      dt '所屬組織'
      dd '將影響此 API 的歸類、管理權限，以及透過使用者的「唯一識別碼」所建立的擁有者關聯。'
      dt '資料欄位 (schema)'
      dd '設定資料表的欄位。若使用非由本系統維護的外部資料庫，則只有經設定的資料欄位可以被存取。'
      dt '主鍵'
      dd '<code>primary key</code>，將影響此 API 特定資源的存取方式。例如設定為「<code>title</code>」，則可以由 <code>/api/&lt;API_存取路徑&gt;/Hello</code> 取得 <code>title</code> 為 「Hello」的項目資料。'.html_safe
      dt '預設資料排序'
      dd 'API 呼叫時的預設資料排序方式。'
      dt '資源擁有者：'
      dd do
        dt '為使用者所擁有'
        dd '是否啟用每筆資料對應到使用者的「資源擁有者」關聯？'
        dt '擁有者可寫入'
        dd '是否啟用「資源擁有者」對此 API 的寫入 (新增、修改、刪除) 權？若開啟，持有具 <code>api:write</code> scope 的 access token 者，將可以寫入屬於對應使用者的 API (send <code>POST</code>、<code>PUT</code>、<code>DELETE</code> requests to <code>api/v1/me/&lt;API_存取路徑&gt;(/*)</code>)。'.html_safe
        dt '擁有者主鍵'
        dd '<code>primary key</code>，使用者的哪項資料存在於此資源集裡？'.html_safe
        dt '擁有者外鍵'
        dd '<code>foreign key</code>，資料中的哪個欄位存放的是使用者的「擁有者主鍵」？'.html_safe
      end
      dt '進階資料庫連線：'
      dd do
        dt 'Database URL'
        dd '若要連線進其他資料庫，取得此 API 的資料，則在此設定資料庫位址。'
        dt '自動維護資料表'
        dd '在此資料集 API 建立、修改或刪除時，自動新增、更新以及刪除相對的資料表。若此資料庫係由其他系統管理，需要關閉此功能以避免修改到其他系統的資料表。'
      end
    end
  end

  index do
    selectable_column
    column(:name) { |data_api| link_to data_api.name, admin_data_api_path(data_api) }
    column(:path)
    column(:accessible)
    column(:public)
    column(:owned_by_user)
    column(:owner_writable)
    column(:organization) { |data_api| data_api.organization.blank? ? nil : link_to(data_api.organization_code, admin_organization_path(data_api.organization)) } if current_admin.root?
    column(:maintain_schema)
    id_column
    column(:manage) { |data_api| link_to '管理資料集', admin_data_api_data_path(data_api_id: data_api.id) }
    column(:more_actions) { |data_api| link_to '作為樣板新增...', new_admin_data_api_path(template_data_api_id: data_api.id) }
    actions
  end

  index as: :detailed_table do
    selectable_column
    column(:name) { |data_api| link_to data_api.name, admin_data_api_path(data_api) }
    column(:table_name)
    column(:path)
    column(:accessible)
    column(:public)
    column(:description)
    column(:data_count)
    column(:owned_by_user)
    column(:owner_writable)
    column(:organization) { |data_api| data_api.organization.blank? ? nil : link_to(data_api.organization_code, admin_organization_path(data_api.organization)) } if current_admin.root?
    column(:maintain_schema)
    column(:primary_key)
    column(:default_order)
    column(:database_url) { |data_api| code { data_api.database_url } }
    column(:owner_primary_key)
    column(:owner_foreign_key)
    id_column
    column(:manage) { |data_api| link_to '管理資料集', admin_data_api_data_path(data_api_id: data_api.id) }
    column(:more_actions) { |data_api| link_to '作為樣板新增...', new_admin_data_api_path(template_data_api_id: data_api.id) }
    actions
  end

  show do
    panel '基本資料' do
      attributes_table_for data_api do
        row(:accessible) { |data_api| data_api.accessible ? status_tag('Yes', class: 'yes') : status_tag('No', class: 'no') }
        row(:public) { |data_api| data_api.public ? status_tag('Yes', class: 'yes') : status_tag('No', class: 'no') }
        row(:name)
        row(:table_name)
        row(:path)
        row(:management_api_key) { |data_api| code { data_api.management_api_key } }
        row('API 存取網址') do |data_api|
          ul do
            li(a("http://#{CoreRSAKeyService.domain}/api/#{data_api.path}", href: "http://#{CoreRSAKeyService.domain}/api/#{data_api.path}", target: '_blank')) if data_api.public
            li(a("http://#{CoreRSAKeyService.domain}/api/v1/me/#{data_api.path}", href: "http://#{CoreRSAKeyService.domain}/api/v1/me/#{data_api.path}", target: '_blank')) if data_api.owner?
          end
        end
        row('資料集維護 API 網址') do |data_api|
          a("http://#{CoreRSAKeyService.domain}/api/data_management/#{data_api.path}?key=#{data_api.management_api_key}", href: "http://#{CoreRSAKeyService.domain}/api/data_management/#{data_api.path}?key=#{data_api.management_api_key}", target: '_blank')
        end
        row(:organization) if current_admin.root? && data_api.organization.present?
        row(:description)
        row(:notes)
        row(:id)
        row(:created_at)
        row(:updated_at)
      end
    end

    panel '外部資料庫' do
      attributes_table_for data_api do
        row(:database_url) { |data_api| code { data_api.database_url } }
        row(:maintain_schema)
      end
    end if data_api.using_outer_database?

    panel '資料綱要' do
      table(class: 'data_api_schema_table') do
        thead do
          th { '欄位名稱' }
          th { '欄位型別' }
          th { '索引' }
        end
        tbody do
          data_api.schema.each do |name, column|
            tr do
              td { name }
              td do
                code { column['type'] }
              end
              td { column['index'] ? status_tag('On', :class => 'yes') : status_tag('Off', :class => 'no') }
            end
          end
        end
      end
    end

    panel '資料表資料' do
      attributes_table_for data_api do
        row(:primary_key)
        row(:default_order) { |data_api| code(data_api.default_order) }
      end
    end

    panel '資料關連' do
      attributes_table_for data_api do
        row(:owned_by_user) { |data_api| data_api.owned_by_user ? status_tag('Yes', class: 'yes') : status_tag('No', class: 'no') }
        row(:owner_writable) { |data_api| data_api.owner_writable ? status_tag('Yes', class: 'yes') : status_tag('No', class: 'no') }
        row(:owner_primary_key)
        row(:owner_foreign_key)
      end
    end

    panel '資料集' do
      para do
        "資料筆數：#{data_api.data_count}"
      end
      para do
        link_to '管理資料集', admin_data_api_data_path(data_api_id: data_api.id)
      end
    end

    panel '更多動作' do
      para do
        link_to '作為樣板新增...', new_admin_data_api_path(template_data_api_id: data_api.id)
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

          if data_api.changes.has_key?('schema') || data_api.changes.has_key?('table_name')
            changes = data_api.test_update

            h3 '資料表變動如下'
            pre JSON.pretty_generate(changes)
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

    if data_api.exception.present?
      div(class: 'errors') do
        panel '系統錯誤' do
          para "#{data_api.name} 更新時遭遇到以下例外："
          br
          para "#{data_api.exception}"
        end
      end
    end

    div(class: 'edit_data_api_form') do
      f.inputs "基本資訊" do
        f.input :accessible
        f.input :public
        f.input :name
        f.input :table_name
        f.input :path
        f.input :management_api_key
        f.input :organization_code, as: :select, collection: options_for_select(Organization.all_for_select, data_api.organization_code) if current_admin.root?
        f.input :description
        f.input :notes
      end

      panel '資料欄位' do
        table(class: 'data_api_schema_table editable') do
          thead do
            th { '欄位名稱' }
            th { '欄位型別' }
            th { '索引' }
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
                  check_box_tag :name, 'true', column['index'], class: :index, id: "data_api_schema_#{column['uuid']}_index", name: "data_api[schema][#{column['uuid']}][index]"
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
                select_tag :name, options_for_select(DataAPI::Schema::COLUMN_TYPES), class: :type, id: "data_api_schema_#{rand_uuid}_type", name: "data_api[schema][#{rand_uuid}][type]"
              end
              td do
                check_box_tag :name, 'true', false, class: :index, id: "data_api_schema_#{rand_uuid}_index", name: "data_api[schema][#{rand_uuid}][index]"
              end
              td do
                hidden_field :name, id: "data_api_schema_#{rand_uuid}_name", name: "data_api[schema][#{rand_uuid}][uuid]"
                a(class: 'add') { '+' }
              end
            end
          end
        end
      end

      f.inputs "資料欄位資訊" do
        f.input :primary_key, hint: "必須是存在的欄位名稱"
        f.input :default_order, hint: "必須使用存在的欄位名稱"
      end

      f.inputs "擁有者對應關係" do
        f.input :owned_by_user
        f.input :owner_writable
        f.input :owner_primary_key, as: :select, collection: options_for_select(DataAPI::OWNER_PRIMARY_KEYS, data_api.owner_primary_key)
        f.input :owner_foreign_key, hint: "必須是存在的欄位名稱"
      end

      f.inputs "進階資料庫連線資訊", class: 'db' do
        li '填寫以下資訊以連線進外部資料庫，來取得 API 資料。否則請忽略此區設定。'
        f.input :database_url, hint: "資料庫位址，支援 PostgreSQL (<code>postgresql://USER:PASSWORD@HOST:PORT/NAME</code>) 以及 MySQL (<code>mysql://USER:PASSWORD@HOST:PORT/NAME</code>)，留空表示使用系統的資料庫".html_safe
        f.input :maintain_schema, hint: "在此資料集 API 建立、修改或刪除時，自動新增、更新以及刪除相對的資料表，若此資料庫係由其他系統管理，請取消勾選此選項<br>若取消自動維護資料表，則需要手動確保資料庫綱要與設定一致，否則會在存取資料時發生錯誤，關閉此功能而又開啟、或搬遷到新資料庫，也需手動設定資料表".html_safe
      end

      f.actions
    end
  end
end
