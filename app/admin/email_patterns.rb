ActiveAdmin.register EmailPattern do
  menu priority: 112, parent: "組織資料"
  config.sort_order = :organization_code_asc, :priority_asc

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  controller do
    def scoped_collection
      super.includes(:organization)
    end
  end

  permit_params do
    params = [:priority, :corresponded_identity, :email_regexp, :uid_postparser, :department_code_postparser, :identity_detail_postparser, :started_at_postparser, :permit_changing_department_in_group, :permit_changing_department_in_organization]
    params.concat [:organization_code, :organization] if current_admin.root?
    params
  end

  filter :organization, if: proc { current_admin.root? }
  filter :email_regexp
  filter :name
  filter :permit_changing_department_in_group
  filter :permit_changing_department_in_organization
  filter :created_at
  filter :updated_at

  sidebar "電子郵件識別模型" do
    para '當使用者新驗證電子郵件時，若電子郵件符合指定的格式，可以自動為使用者開通特定身份，並依據正規表示式截取出的資料，為該身份設定部門、識別碼、描述、開始日期。'
    dl do
      dt '優先級'
      dd '數字越小優先級越高，較嚴謹的規則應被排在較高的優先級。'
      dt '對應身份'
      dd '新認證了符合此規則 email 的使用者該被賦予的身份。'
      dt 'Email 正規表示式'
      dd do
        text_node '指定符合的 Regexp。可使用 named capturing groups 抓取資料。可用的 group name 有：'
        dl do
          dt '<uid>'
          dd '識別碼，在組織內必須唯一。若沒有指定，將會以全 email 作為識別碼。'
          dt '<department_code>'
          dd '部門代碼。'
          dt '<identity_detail>'
          dd '身份細節資料。'
          dt '<started_at>'
          dd '指定該身份的開始日期。'
        end
      end
      dt '識別碼後處理運算式'
      dd '從 email 中抓取出 <uid> 字串後，將其轉換成「識別碼」資料的 JavaScript 程式碼。'
      dt '部門代碼後處理運算式'
      dd '從 email 中抓取出 <department_code> 字串後，將其轉換成「部門代碼」資料的 JavaScript 程式碼。'
      dt '詳細身份後處理運算式'
      dd '從 email 中抓取出 <identity_detail> 字串後，將其轉換成「詳細身份」資料的 JavaScript 程式碼。'
      dt '身份開始日期後處理運算式'
      dd '從 email 中抓取出 <started_at> 字串後，將其轉換成「身份開始日期」資料的 JavaScript 程式碼。'
      dt '允許切換到同類型的部門'
      dd '若設為「是」，則使用者可以更改此身份到同組織、同種類的任意部門。'
      dt '允許切換到同組織的部門'
      dd '若設為「是」，則使用者可以更改此身份到同組織的任意部門。'
    end
  end

  index do
    selectable_column
    column(:organization) { |email_pattern| link_to email_pattern.organization_code, admin_organization_path(email_pattern.organization) } if current_admin.root?
    column(:priority) { |email_pattern| link_to email_pattern.priority, admin_email_pattern_path(email_pattern) }
    column(:corresponded_identity)
    column :email_regexp do |email_pattern|
      code(truncate(email_pattern.email_regexp, omision: "...", length: 120))
    end
    id_column
    actions
  end

  form do |f|
    f.inputs do
      f.input :organization_code, as: :select, collection: options_for_select(Organization.all.map { |u| [u.name, u.code] }, email_pattern.organization_code) if current_admin.root?
      f.input :priority, hint: "數字越小優先級越高，較嚴謹的規則應被排在較高的優先級"
      f.input :corresponded_identity, as: :select, collection: options_for_select(UserIdentity::IDENTITES.map { |k, v| [k, k] }, email_pattern.corresponded_identity)
      f.input :email_regexp
      f.input :uid_postparser, hint: "JavaScript 程式碼，可用變數 n 取得原始資料，必須返回一個字串，留白表示不處理，例如：`n.toLowerCase()`"
      f.input :department_code_postparser, hint: "JavaScript 程式碼，可用變數 n 取得原始資料，必須返回一個字串，留白表示不處理，例如：`'0' + n`"
      f.input :identity_detail_postparser, hint: "JavaScript 程式碼，可用變數 n 取得原始資料，必須返回一個字串，留白表示不處理，例如：`switch (n.toLowerCase()) { case 'a': 'a'; break; case 'b': 'bachelor'; break; case 'm': 'master'; break; case 'd': 'doctor'; break; }`"
      f.input :started_at_postparser, hint: "JavaScript 程式碼，可用變數 n 取得原始資料，必須返回一個日期物件，留白表示不處理，例如：`new Date((parseInt(n)+1911) + '-9')`"
    end
    f.actions
  end
end
