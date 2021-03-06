FactoryGirl.define do
  factory :yzu_organization, parent: :organization do
    code 'YZU'
    name '元智大學'
    short_name '元智'
    after(:create) do |yzu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [
          ["YZU", "EG",    "工程學院", "工程學院", nil, 'C' ],
          ["YZU", "MA",    "管理學院", "管理學院", nil, 'C' ],
          ["YZU", "HS",    "人文社會學院", "人文社會學院", nil, 'C' ],
          ["YZU", "IN",    "資訊學院", "資訊學院", nil, 'C' ],
          ["YZU", "EC",    "電機通訊學院", "電機通訊學院", nil, 'C' ],

          ["YZU", "ME00",  "機械工程學系", "機械工程學系", "EG", 'D' ],
          ["YZU", "ME01",  "機械工程學系學士班", "機械工程學系學士班", "ME00", 'BC' ],
          ["YZU", "ME02",  "機械工程學系碩士班", "機械工程學系碩士班", "ME00", 'MC' ],
          ["YZU", "ME03",  "機械工程學系博士班", "機械工程學系博士班", "ME00", 'DC' ],
          ["YZU", "CH00",  "化學工程與材料科學學系", "化學工程與材料科學學系", "EG", 'BC' ],
          ["YZU", "CH01",  "化學工程與材料科學學系學士班", "化學工程與材料科學學系學士班", "CH00", 'BC' ],
          ["YZU", "CH02",  "化學工程與材料科學學系碩士班", "化學工程與材料科學學系碩士班", "CH00", 'MC' ],
          ["YZU", "CH03",  "化學工程與材料科學學系博士班", "化學工程與材料科學學系博士班", "CH00", 'DC' ],
          ["YZU", "IE00",  "工業工程與管理學系", "工業工程與管理學系", "EG", 'D' ],
          ["YZU", "IE01",  "工業工程與管理學系學士班", "工業工程與管理學系學士班", "IE00", 'BC' ],
          ["YZU", "IE02",  "工業工程與管理學系碩士班", "工業工程與管理學系碩士班", "IE00", 'MC' ],
          ["YZU", "IE03",  "工業工程與管理學系博士班", "工業工程與管理學系博士班", "IE00", 'DC' ],
          ["YZU", "BI00",  "生物科技與工程研究所", "生物科技與工程研究所", "EG", 'D' ],
          ["YZU", "BI02",  "生物科技與工程研究所碩士班", "生物科技與工程研究所碩士班", "BI00", 'MC' ],
          ["YZU", "ERP",   "先進能源碩士學位學程", "先進能源碩士學位學程", "EG", 'P' ],

          ["YZU", "CM01",  "管理學院學士班", "管理學院學士班", "MA", 'BC' ],
          ["YZU", "CM021", "管理學院經營管理碩士班", "管理學院經營管理碩士班", "MA", 'MC' ],
          ["YZU", "CM022", "管理學院財務金融暨會計碩士班", "管理學院財務金融暨會計碩士班", "MA", 'MC' ],
          ["YZU", "CM03",  "管理學院博士班", "管理學院博士班", "MA", 'DC' ],
          ["YZU", "CM04",  "管理學院管理碩士在職專班", "管理學院管理碩士在職專班", "MA", 'JC' ],
          ["YZU", "CM05",  "管理學院行銷學群", "管理學院行銷學群", "MA", 'G' ],
          ["YZU", "CM06",  "管理學院科技管理學群", "管理學院科技管理學群", "MA", 'G' ],
          ["YZU", "CM07",  "管理學院財務金融學群", "管理學院財務金融學群", "MA", 'G' ],
          ["YZU", "CM08",  "管理學院國際企業學群", "管理學院國際企業學群", "MA", 'G' ],
          ["YZU", "CM09",  "管理學院組織管理學群", "管理學院組織管理學群", "MA", 'G' ],
          ["YZU", "CM10",  "管理學院會計學群", "管理學院會計學群", "MA", 'G' ],
          ["YZU", "CM11",  "管理學院學士英語專班", "管理學院學士英語專班", "MA", 'BC' ],

          ["YZU", "FL00",  "應用外語學系", "應用外語學系", "HS", 'D' ],
          ["YZU", "FL01",  "應用外語學系學士班", "應用外語學系學士班", "FL00", 'BC' ],
          ["YZU", "FL02",  "應用外語學系碩士班", "應用外語學系碩士班", "FL00", 'MC' ],
          ["YZU", "CC00",  "中國語文學系", "中國語文學系", "HS", 'D' ],
          ["YZU", "CC01",  "中國語文學系學士班", "中國語文學系學士班", "CC00", 'BC' ],
          ["YZU", "CC02",  "中國語文學系碩士班", "中國語文學系碩士班", "CC00", 'MC' ],
          ["YZU", "AD00",  "藝術與設計學系", "藝術與設計學系", "HS", 'D' ],
          ["YZU", "AD01",  "藝術與設計學系學士班", "藝術與設計學系學士班", "AD00", 'BC' ],
          ["YZU", "AD02",  "藝術與設計學系(藝術管理碩士班)", "藝術與設計學系(藝術管理碩士班)", "HS", 'MC' ],
          ["YZU", "SC00",  "社會暨政策科學學系", "社會暨政策科學學系", "HS", 'D' ],
          ["YZU", "SC01",  "社會暨政策科學學系學士班", "社會暨政策科學學系學士班", "SC00", 'BC' ],
          ["YZU", "SC02",  "社會暨政策科學學系碩士班", "社會暨政策科學學系碩士班", "SC00", 'MC' ],
          ["YZU", "CL01",  "文化產業與文化政策博士學位學程", "文化產業與文化政策博士學位學程", "HS", "P"],

          ["YZU", "CS00",  "資訊工程學系", "資訊工程學系", "IN", 'D' ],
          ["YZU", "CS01",  "資訊工程學系學士班", "資訊工程學系學士班", "CS00", 'BC' ],
          ["YZU", "CS02",  "資訊工程學系碩士班", "資訊工程學系碩士班", "CS00", 'MC' ],
          ["YZU", "CS03",  "資訊工程學系博士班", "資訊工程學系博士班", "CS00", 'DC' ],

          ["YZU", "IM00",  "資訊管理學系", "資訊管理學系", "IN", 'D' ],
          ["YZU", "IM01",  "資訊管理學系學士班", "資訊管理學系學士班", "IM00", 'BC' ],
          ["YZU", "IM02",  "資訊管理學系碩士班", "資訊管理學系碩士班", "IM00", 'MC' ],
          ["YZU", "IM03",  "資訊管理學系博士班", "資訊管理學系博士班", "IM00", 'DC' ],
          ["YZU", "IC00",  "資訊傳播學系", "資訊傳播學系", "IN", 'D' ],
          ["YZU", "IC01",  "資訊傳播學系學士班", "資訊傳播學系學士班", "IC00", 'BC' ],
          ["YZU", "IC02",  "資訊傳播學系碩士班", "資訊傳播學系碩士班", "IN", 'IC00' ],
          ["YZU", "SIP",   "資訊社會學碩士學位學程", "資訊社會學碩士學位學程", "IN", 'P' ],
          ["YZU", "CBP",   "生物與醫學資訊碩士學位學程", "生物與醫學資訊碩士學位學程", "IN", 'P' ],

          ["YZU", "EE00",  "電機工程學系", "電機工程學系", "EC", 'D' ],
          ["YZU", "EE01",  "電機工程學系學士班", "電機工程學系學士班", "EE00", 'BC' ],
          ["YZU", "EE02",  "電機工程學系碩士班", "電機工程學系碩士班", "EE00", 'MC' ],
          ["YZU", "EE03",  "電機工程學系博士班", "電機工程學系博士班", "EE00", 'DC' ],
          ["YZU", "CN00",  "通訊工程學系", "通訊工程學系", "EC", 'D' ],
          ["YZU", "CN01",  "通訊工程學系學士班", "通訊工程學系學士班", "CN00", 'BC' ],
          ["YZU", "CN02",  "通訊工程學系碩士班", "通訊工程學系碩士班", "CN00", 'MC' ],
          ["YZU", "CN03",  "通訊工程學系博士班", "通訊工程學系博士班", "CN00", 'DC' ],
          ["YZU", "EO00",  "光電工程學系", "光電工程學系", "EC", 'D' ],
          ["YZU", "EO01",  "光電工程學系學士班", "光電工程學系學士班", "EO00", 'BC' ],
          ["YZU", "EO02",  "光電工程學系碩士班", "光電工程學系碩士班", "EO00", 'MC' ],
          ["YZU", "EO03",  "光電工程學系博士班", "光電工程學系博士班", "EO00", 'DC' ],

          ["YZU", "GE",    "通識教學部", "通識教學部", nil, 'U' ],
          ["YZU", "MT",    "軍訓室", "軍訓室", nil, 'U' ],
          ["YZU", "PL",    "體育室", "體育室", nil, 'U' ],
          ["YZU", "IL",    "國際語言文化中心", "國際語言文化中心", nil, 'U' ],
          ["YZU", "OIA",   "國際兩岸事務室", "國際兩岸事務室", nil, 'U' ]
        ], :validate => false
      )

      if yzu.email_patterns.count < 1
        create(:yzu_student_email_pattern)
        create(:yzu_staff_email_pattern)
      end
    end
  end

  factory :yzu_student_email_pattern, parent: :email_pattern do
    priority 15
    organization { Organization.find_by(code: 'YZU') || create(:yzu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^s(?<uid>(?<started_at>\\d{3})\\d{2,10})@mail\\.yzu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :yzu_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'YZU') || create(:yzu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@saturn\\.yzu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end
end
