ActiveAdmin.register Organization do
  menu priority: 110, parent: 'organization', if: proc { current_admin.root? }
  config.sort_order = :code_asc

  scope_to(if: proc { current_admin.scoped? }) { current_admin }

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  permit_params :code, :name, :short_name, :enabled,
                email_patterns_attributes: [
                  :_destroy,
                  :id,
                  :priority,
                  :corresponded_identity,
                  :email_regexp,
                  :uid_postparser,
                  :identity_detail_postparser,
                  :department_code_postparser,
                  :started_at_postparser,
                  :permit_changing_department_in_group,
                  :permit_changing_department_in_organization
                ],
                departments_attributes: [
                  :_destroy,
                  :id,
                  :code,
                  :short_name,
                  :name,
                  :parent,
                  :parent_code,
                  :group
                ]

  filter :code_cont
  filter :name
  filter :short_name
  filter :enabled
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column(:code) { |organization| link_to organization.code, admin_organization_path(organization) }
    column(:short_name) { |organization| link_to organization.short_name, admin_organization_path(organization) }
    column(:name) { |organization| link_to organization.name, admin_organization_path(organization) }
    column(:enabled)
    id_column
    actions
  end

  sidebar "組織資料", only: [:edit, :new, :show] do
    ul do
      li do
        strong '基本資料：'
        br
        text_node '代碼、簡稱、全名等基本資料。'
      end
      li do
        strong 'Email 模型：'
        br
        text_node '當使用者驗證 Email 時，若符合模型所設規則，會自動開通該校身份，並填入資料。'
      end
      li do
        strong '部門：'
        br
        text_node '部門可以隸屬於另一個部門。'
      end
    end
    para '詳情可參考各項說明。'
  end

  show do
    attributes_table do
      row(:code)
      row(:name)
      row(:short_name)
      row(:enabled)
    end

    panel 'Email 辨識模型' do
      attributes_table_for organization.email_patterns do
        row(:priority)
        row(:identity)
        row(:email_regexp) { |ep| code(ep.email_regexp) }
        row(:uid_postparser) { |ep| code(ep.uid_postparser) }
        row(:identity_detail_postparser) { |ep| code(ep.identity_detail_postparser) }
        row(:department_code_postparser) { |ep| code(ep.department_code_postparser) }
        row(:started_at_postparser) { |ep| code(ep.started_at_postparser) }
        row(:permit_changing_department_in_group)
        row(:permit_changing_department_in_organization)
      end
    end

    panel '部門資料' do
      table_for organization.departments do
        column(:parent)
        column(:code)
        column(:short_name)
        column(:name)
        column(:group)
      end
    end
  end

  form do |f|
    f.inputs "基本資料" do
      f.input :code
      f.input :name
      f.input :short_name
      f.input :enabled
    end

    # f.inputs "資料集" do

    #   tabs do

        panel 'Email 辨識模型' do
          # f.has_many :email_patterns, allow_destroy: true, new_record: true, sortable: :priority do |ep|
          f.has_many :email_patterns, allow_destroy: true, new_record: true do |ep|
            ep.input :priority, hint: "數字越小優先級越高，較嚴謹的規則應被排在較高的優先級"
            ep.input :email_regexp, hint: "可使用 named capturing groups 抓取資料，有效的 group name 有：uid (學號)、identity_detail (身份細節)、department_code (系所代碼)、unit_code (所屬單位代碼)、started_at (身份開始日期)，例如：`^(?<uid>(?<identity_detail>[aAbmdBMD])(?<started_at>\d*)(?<department_code>\d{2})\d{3})@mail\.ntust\.edu\.tw$`"

            ep.input :corresponded_identity, as: :select, collection: UserIdentity::IDENTITIES.keys, hint: "符合此規則的使用者該被賦予的身份"

            ep.input :uid_postparser, hint: "將抓取出的 <uid> 字串轉換成正確學號資料的 JavaScript 程式碼，可用變數 n 取得原始資料，空白表示不處理，例如：`n.toLowerCase()`"
            ep.input :identity_detail_postparser, hint: "將抓取出的 <identity_detail> 字串轉換成正確詳細身份資料的 JavaScript 程式碼，可用變數 n 取得原始資料，空白表示不處理，例如：`switch (n.toLowerCase()) { case 'a': 'a'; break; case 'b': 'bachelor'; break; case 'm': 'master'; break; case 'd': 'doctor'; break; }`"
            ep.input :department_code_postparser, hint: "將抓取出的 <department_code> 字串轉換成正確系所代碼資料的 JavaScript 程式碼，可用變數 n 取得原始資料，空白表示不處理"
            ep.input :started_at_postparser, hint: "將抓取出的 <started_at> 字串轉換成正確開始日期資料的 JavaScript 程式碼，可用變數 n 取得原始資料，空白表示不處理，例如：`new Date((parseInt(n)+1911) + '-9')`"
            ep.input :permit_changing_department_in_group, hint: "使用者可以在「類型代號」相同的部門間切換"
            ep.input :permit_changing_department_in_organization, hint: "使用者可以在組織的所有部門間切換"
          end
        end

        panel '部門資料' do
          f.has_many :departments, allow_destroy: true, new_record: true do |department|
            department.input :code
            department.input :short_name
            department.input :name
            department.input :group
            department.input :parent_code
          end
        end

    #   end
    # end

    f.actions
  end
end
