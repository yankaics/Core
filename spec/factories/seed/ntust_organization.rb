FactoryGirl.define do
  factory :ntust_organization, parent: :organization do
    code 'NTUST'
    name '國立臺灣科技大學'
    short_name '台科大'
    after(:create) do |ntust|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [

          ["NTUST", "U01", "校長室", "校長室", nil, 'U'],
          ["NTUST", "U02", "副校長室", "副校長室", nil, 'U'],
          ["NTUST", "U03", "教務處", "教務處", nil, 'U'],
          ["NTUST", "U0301", "註冊組", "註冊組", "U03", 'U'],
          ["NTUST", "U0302", "研教組", "研教組", "U03", 'U'],
          ["NTUST", "U0303", "課務組", "課務組", "U03", 'U'],
          ["NTUST", "U0304", "出版組", "出版組", "U03", 'U'],
          ["NTUST", "U0305", "推廣組", "推廣組", "U03", 'U'],
          ["NTUST", "U0306", "視聽教學組", "視聽教學組", "U03", 'U'],
          ["NTUST", "U04", "學務處", "學務處", nil, 'U'],
          ["NTUST", "U0401", "軍訓室", "軍訓室", "U04", 'U'],
          ["NTUST", "U0402", "生活輔道導組", "生活輔道導組", "U04", 'U'],
          ["NTUST", "U0403", "學生活動組", "學生活動組", "U04", 'U'],
          ["NTUST", "U0404", "衛生保健組", "衛生保健組", "U04", 'U'],
          ["NTUST", "U0405", "諮商輔導組", "諮商輔導組", "U04", 'U'],
          ["NTUST", "U0406", "就業輔導組", "就業輔導組", "U04", 'U'],
          ["NTUST", "U0407", "社會服務中心", "社會服務中心", "U04", 'U'],
          ["NTUST", "U0408", "生活教育中心", "生活教育中心", "U04", 'U'],
          ["NTUST", "U05", "總務處", "總務處", nil, 'U'],
          ["NTUST", "U0501", "事務組", "事務組", "U05", 'U'],
          ["NTUST", "U0502", "營繕組", "營繕組", "U05", 'U'],
          ["NTUST", "U0503", "出納組", "出納組", "U05", 'U'],
          ["NTUST", "U0504", "文書組", "文書組", "U05", 'U'],
          ["NTUST", "U0505", "保管組", "保管組", "U05", 'U'],
          ["NTUST", "U06", "研發處", "研發處", nil, 'U'],
          ["NTUST", "U07", "國際事務處", "國際事務處", nil, 'U'],
          ["NTUST", "U08", "產學營運中心", "產學營運中心", nil, 'U'],
          ["NTUST", "U09", "秘書室", "秘書室", nil, 'U'],
          ["NTUST", "U10", "人事室", "人事室", nil, 'U'],
          ["NTUST", "U11", "主計室", "主計室", nil, 'U'],
          ["NTUST", "U12", "環安室", "環安室", nil, 'U'],
          ["NTUST", "U13", "體育室", "體育室", nil, 'U'],
          ["NTUST", "U14", "圖書館", "圖書館", nil, 'U'],
          ["NTUST", "U15", "教學資源中心", "教學資源中心", nil, 'U'],
          ["NTUST", "U16", "電算中心", "電算中心", nil, 'U'],
          ["NTUST", "U17", "重點計畫辦公室", "重點計畫辦公室", nil, 'U'],
          ["NTUST", "U18", "校級中心", "校級中心", nil, 'U'],

          ["NTUST", "C01", "管理學院", "管院", nil, 'C'],
          ["NTUST", "C02", "電資學院", "電資", nil, 'C'],
          ["NTUST", "C03", "工程學院", "工程", nil, 'C'],
          ["NTUST", "C04", "設計學院", "設計", nil, 'C'],
          ["NTUST", "C05", "人社學院", "人社", nil, 'C'],
          ["NTUST", "C06", "精誠學院", "精誠", nil, 'C'],

          ["NTUST", "D01", "工業管理系", "工管系", "C01", 'D'],
          ["NTUST", "D02", "電子工程系", "電子系", "C02", 'D'],
          ["NTUST", "D03", "機械工程系", "機械系", "C03", 'D'],
          ["NTUST", "D04", "材料科學與工程學系", "材料系", "C03", 'D'],
          ["NTUST", "D05", "營建工程系", "營建系", "C03", 'D'],
          ["NTUST", "D06", "化學工程系", "化工系", "C03", 'D'],
          ["NTUST", "D07", "電機工程系", "電機系", "C02", 'D'],
          ["NTUST", "D08", "企業管理系", "企管系", "C01", 'D'],
          ["NTUST", "D09", "資訊管理系", "資管系", "C01", 'D'],
          ["NTUST", "D10", "工商業設計系", "設計系", "C04", 'D'],
          ["NTUST", "D11", "數位學習與教育研究所", "數位學習與教育研究所", "C05", 'D'],
          ["NTUST", "D12", "自動化及控制研究所", "自動化及控制研究所", "C03", 'D'],
          ["NTUST", "D13", "建築系", "建築系", "C04", 'D'],
          ["NTUST", "D14", "材料科技研究所", "材料科技研究所", "C03", 'D'],
          ["NTUST", "D15", "資訊工程系", "資工系", "C02", 'D'],
          ["NTUST", "D16", "管理研究所", "管理研究所", "C01", 'D'],
          ["NTUST", "D17", "應用外語系", "應外系", "C05", 'D'],
          ["NTUST", "D18", "財務金融研究所", "財務金融研究所", "C01", 'D'],
          ["NTUST", "D19", "光電工程研究所", "光電工程研究所", "C02", 'D'],
          ["NTUST", "D20", "科技管理研究所", "科技管理研究所", "C01", 'D'],
          ["NTUST", "D21", "管理學院 MBA", "管理學院 MBA", "C01", 'D'],
          ["NTUST", "D22", "工程技術研究所", "工程技術研究所", "C06", 'D'],
          ["NTUST", "D23", "醫學工程研究所", "醫學工程研究所", "C06", 'D'],
          ["NTUST", "D24", "專利研究所", "專利研究所", "C06", 'D'],
          ["NTUST", "D30", "不分系學士班", "不分系", "C06", 'D'],
          ["NTUST", "D31", "工程學士班", "工程學士班", "C03", 'D'],
          ["NTUST", "D32", "電資學士班", "電資學士班", "C02", 'D'],
          ["NTUST", "D33", "管理學士班", "管理學士班", "C01", 'D'],
          ["NTUST", "D34", "創意設計學士班", "創意設計學士班", "C04", 'D'],

        ], :validate => false
      )

      if ntust.email_patterns.count < 1
        create(:ntust_student_email_pattern)
        create(:ntust_staff_email_pattern)
      end
    end
  end

  factory :ntust_student_email_pattern, parent: :email_pattern do
    priority 10
    organization { Organization.find_by(code: 'NTUST') || create(:ntust_organization) }
    corresponded_identity UserIdentity::IDENTITES[:student]
    email_regexp '^(?<uid>(?<identity_detail>[aAbmdBMD])(?<started_at>\\d*)(?<department_code>\\d{2})\\d{3})@mail\\.ntust\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    department_code_postparser "'D' + n"
    identity_detail_postparser "switch (n.toLowerCase()) { case 'a': 'a'; break; case 'b': 'bachelor'; break; case 'm': 'master'; break; case 'd': 'doctor'; break; }"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
  end

  factory :ntust_staff_email_pattern, parent: :email_pattern do
    priority 20
    organization { Organization.find_by(code: 'NTUST') || create(:ntust_organization) }
    corresponded_identity UserIdentity::IDENTITES[:staff]
    email_regexp '^(?<uid>.+)@mail\\.ntust\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
  end
end
