FactoryGirl.define do
  factory :ttu_organization, parent: :organization do
    code 'TTU'
    name '大同大學'
    short_name '大同'
    after(:create) do |ttu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [

          ["TTU", "V",  "媒體設計學系", "媒體系", nil, 'C'],
          ["TTU", "V1", "媒體設計學系 數位遊戲設計組", "媒體系遊戲組", "V", 'G'],
          ["TTU", "V2", "媒體設計學系 互動媒體設計組", "媒體系媒體組", "V", 'G'],

          ["TTU", "A", "應用數學系", "應數系", nil, 'D'],

          ["TTU", "B",  "事業經營學系", "經營系所", nil, 'C'],
          ["TTU", "BB", "事業經營系", "經營系", "B", 'D'],
          ["TTU", "BI", "事業經營研究所", "經營所", "B", 'D'],
          ["TTU", "BM", "事業經營研究所碩士班", "經營所碩班", "BI", 'MC'],
          ["TTU", "BJ", "事業經營研究所碩士在職專班", "經營所在職班", "BI", 'JC'],

          ["TTU", "I",  "資訊工程學系", "資工系所", nil, 'C'],
          ["TTU", "IB", "資訊工程系", "資工系", "I", 'D'],
          ["TTU", "II", "資訊工程研究所", "資工所", "I", 'D'],
          ["TTU", "IM", "資訊工程研究所碩士班", "資工所碩班", "II", 'MC'],
          ["TTU", "ID", "資訊工程研究所博士班", "資工所博班", "II", 'DC'],
          ["TTU", "IJ", "資訊工程研究所碩士在職專班", "資工所在職班", "II", 'JC'],

          ["TTU", "S",  "生物工程學系", "生工系所", nil, 'C'],
          ["TTU", "SB", "生物工程系", "生工系", "S", 'D'],
          ["TTU", "SI", "生物工程研究所", "生工所", "S", 'D'],
          ["TTU", "SM", "生物工程研究所碩士班", "生工所碩班", "SI", 'MC'],
          ["TTU", "SD", "生物工程研究所博士班", "生工所博班", "SI", 'DC'],
          ["TTU", "SJ", "生物工程研究所碩士在職專班", "生工所在職班", "SI", 'JC'],

          ["TTU", "N",  "資訊經營學系", "資經系所", nil, 'C'],
          ["TTU", "NB", "資訊經營系", "資經系", "N", 'D'],
          ["TTU", "NI", "資訊經營研究所", "資經所", "N", 'D'],
          ["TTU", "NM", "資訊經營研究所碩士班", "資經所碩班", "NI", 'MC'],
          ["TTU", "NJ", "資訊經營研究所碩士在職專班", "資經所在職班", "NI", 'JC'],

          ["TTU", "T",  "材料工程學系", "材料系所", nil, 'C'],
          ["TTU", "TB", "材料工程系", "材料系", "T", 'D'],
          ["TTU", "TI", "材料工程研究所", "材料所", "T", 'D'],
          ["TTU", "TM", "材料工程研究所碩士班", "材料所碩班", "TI", 'D'],
          ["TTU", "TD", "材料工程研究所博士班", "材料所博班", "TI", 'D'],

          ["TTU", "C",   "化學工程學系", "化工系所", nil, 'C'],
          ["TTU", "CB",  "化學工程系", "化工系", "C", 'D'],
          ["TTU", "CI",  "化學工程研究所", "化工所", "C", 'D'],
          ["TTU", "CM",  "化學工程研究所碩士班", "化工所碩班", "CI", 'MC'],
          ["TTU", "CD",  "化學工程研究所博士班", "化工所博班", "CI", 'DC'],


          ["TTU", "M",   "機械工程學系", "機械系所", nil, 'C'],
          ["TTU", "MB",  "機械工程系", "機械系", "M", 'D'],
          ["TTU", "M1",  "機械工程學系 電子機械組", "機械系電子組", "MB", 'G'],
          ["TTU", "M2",  "機械工程學系 精密機械組", "機械系精密組", "MB", 'G'],
          ["TTU", "MI",  "機械工程研究所", "機械所", "M", 'D'],
          ["TTU", "MM",  "機械工程研究所碩士班", "機械所碩班", "MI", 'MC'],
          ["TTU", "MD",  "機械工程研究所博士班", "機械所博班", "MI", 'DC'],
          ["TTU", "MG",  "物理教學組", "物理教學組", "M", 'G'],


          ["TTU", "P",  "能源科技碩士學位學程", "能源科技碩士學位學程", nil, 'P'],
          ["TTU", "PC", "能源科技碩士學位學程班", "能源科技碩士學位學程班", "P", 'PC'],

          ["TTU", "O", "光電工程研究所", "光電所", nil, 'C'],
          ["TTU", "OM", "光電工程研究所碩士班", "光電所碩班", "O", 'MC'],
          ["TTU", "OD", "光電工程研究所博士班", "光電所博班", "O", 'DC'],


          ["TTU", "D", "工業設計學系", "工設系所", nil, 'C'],
          ["TTU", "DB", "工業設計系", "工設系", "D", 'D'],
          ["TTU", "DI", "工業設計研究所", "工設所", "D", 'D'],
          ["TTU", "DM", "工業設計研究所碩士班", "工設所碩班", "DI", 'MC'],
          ["TTU", "DD", "工業設計研究所博士班", "工設所博班", "DI", 'DC'],
          ["TTU", "DJ", "工業設計研究所碩士在職專班", "工設所在職班", "DI", 'JC'],

          ["TTU", "K", "設計科學研究所", "設科所", nil, 'C'],
          ["TTU", "KM", "設計科學研究所博士班", "設科所博班", "K", 'DC'],

          ["TTU", "E",   "電機工程學系", "電機系所", nil, 'C'],
          ["TTU", "EB",  "電機工程系", "電機系", "E", 'D'],
          ["TTU", "E1",  "電機工程學系 電機與系統組", "電機系電機系統組", "EB", 'G'],
          ["TTU", "E2",  "電機工程學系 電子與通訊組", "電機系電子通訊組", "EB", 'G'],
          ["TTU", "EI",  "電機工程研究所", "電機所", "E", 'D'],
          ["TTU", "EM",  "電機工程研究所碩士班", "電機所碩班", "EI", 'MC'],
          ["TTU", "ED",  "電機工程研究所博士班", "電機所博班", "EI", 'DC'],
          ["TTU", "EJ",  "電機工程研究所碩士在職專班", "電機所在職班", "EI", 'JC'],

          ["TTU", "W", "通訊工程研究所", "通訊所", nil, 'C'],
          ["TTU", "WM", "通訊工程研究所碩士班", "通訊所碩班", "W", 'MC'],
          ["TTU", "WD", "通訊工程研究所博士班", "通訊所博班", "W", 'DC'],
          ["TTU", "WJ", "通訊工程研究所碩士在職專班", "通訊所在職班", "W", 'JC'],

          ["TTU", "L", "應用外語學系", "應外系", nil, 'D'],

          ["TTU", "Q", "工程管理學位學程", "工程管理學位學程", nil, 'P'],
          ["TTU", "QJ", "工程管理碩士在職專班", "工程管理碩士在職專班", "Q", 'PC']
        ], :validate => false
      )

      if ttu.email_patterns.count < 1
        create(:ttu_student_email_pattern)
        create(:ttu_staff_email_pattern)
      end
    end
  end

  factory :ttu_student_email_pattern, parent: :email_pattern do
    priority 15
    organization { Organization.find_by(code: 'TTU') || create(:ttu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^(?<uid>[uged](?<started_at>\\d{3})\\d{2,10})@ms\\.ttu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase().replace('u', '4').replace('g', '6').replace('e', '7').replace('d', '8')"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :ttu_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'TTU') || create(:ttu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@ms\\.ttu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end
end
