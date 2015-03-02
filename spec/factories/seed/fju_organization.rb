FactoryGirl.define do
  factory :fju_organization, parent: :organization do
    code 'FJU'
    name '輔仁大學'
    short_name '輔仁'
    after(:create) do |fju|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [
          ["FJU", "LI", "文學院", "文學院", nil, 'C'],
          ["FJU", "D01", "中文學系", "中文系", "LI", 'D'],
          ["FJU", "D02", "歷史學系", "歷史系", "LI", 'D'],
          ["FJU", "D03", "哲學系", "哲學系", "LI", 'D'],

          ["FJU", "AR", "藝術學院", "藝術學院", nil, 'C'],
          ["FJU", "D80", "音樂學系", "音樂系", "AR", 'D'],
          ["FJU", "D81", "應用美術學系", "應美系", "AR", 'D'],
          ["FJU", "D82", "景觀設計學系", "景觀系", "AR", 'D'],
          ["FJU", "C0J", "藝術與文化創意學士學位學程", "文創學程", "AR", 'P'],

          ["FJU", "CM", "傳播學院", "傳播學院", nil, 'C'],
          ["FJU", "D11", "影像傳播學系", "影傳系", "CM", 'D'],
          ["FJU", "D12", "新聞傳播學系", "新傳系", "CM", 'D'],
          ["FJU", "D13", "廣告傳播學系", "廣告系", "CM", 'D'],
          ["FJU", "G09", "大眾傳播學研究所", "大傳所", "CM", 'D'],

          ["FJU", "ED", "教育學院", "教育學院", nil, 'C'],
          ["FJU", "D16", "體育學系", "體育系", "ED", 'D'],
          ["FJU", "D10", "圖書資訊學系", "圖資系", "ED", 'D'],
          ["FJU", "G14", "教育領導與發展研究所", "教育領導與發展研究所", "ED", 'D'],
          ["FJU", "ED", "師資培育中心", "師資培育中心", nil, 'C'],
          # ["FJU", "",  "運動休閒管理學士學位學程", "運動休閒管理學士學位學程","", 'P'],

          ["FJU", "MD", "醫學院", "醫學院", nil, 'C'],
          ["FJU", "D91", "護理學系", "護理系", "MD", 'D'],
          ["FJU", "D92", "公共衛生學系", "公衛系", "MD", 'D'],
          ["FJU", "D94", "醫學系", "醫學系", "MD", 'D'],
          ["FJU", "D95", "臨床心理學系", "臨心系", "MD", 'D'],
          ["FJU", "D96", "職能治療學系", "職治系", "MD", 'D'],
          ["FJU", "D98", "呼吸治療學系", "呼吸系", "MD", 'D'],
          ["FJU", "G97", "基礎醫學研究所", "基礎醫學研究所", "MD", 'D'],
          # ["FJU", "",  "跨專業長期照護碩士學位學程", "跨專業長期照護碩士學位學程","", 'P'],
          # ["FJU", "DK09", "老人學學程", "老人學學程", "", 'P'],
          # ["FJU", "",  "老人長期照護學程", "老人長期照護學程","", 'P'],

          ["FJU", "SE", "理工學院", "理工學院", nil, 'C'],
          ["FJU", "D36", "數學系", "數學系", "SE", 'D'],
          ["FJU", "D30", "數學系純數學組", "數學系純數學組", "SE", 'G'],
          ["FJU", "D31", "數學系應用數學組", "數學系應用數學組", "SE", 'G'],
          ["FJU", "D55", "物理學系", "物理系", "SE", 'D'],
          ["FJU", "D33", "化學系", "化學系", "SE", 'D'],
          ["FJU", "D54", "生命科學系", "生科系", "SE", 'D'],
          ["FJU", "D51", "資訊工程學系", "資工系", "SE", 'D'],
          ["FJU", "D19", "電機工程學系", "電機系", "SE", 'D'],
          # ["FJU", "",  "醫學資訊與創新應用學士學位學程", "醫學資訊與創新應用學士學位學程","", 'P'],
          # ["FJU", "",  "應用科學與工程研究所博士班", "應用科學與工程研究所博士班","", 'P'],
          # ["FJU", "",  "軟體工程與數位創意學士學位學程", "軟體工程與數位創意學士學位學程","", 'P'],

          ["FJU", "FL", "外語學院", "外語學院", nil, 'C'],
          ["FJU", "D20", "英國語文學系", "英文系", "FL", 'D'],
          ["FJU", "D22", "法國語文學系", "法文系", "FL", 'D'],
          ["FJU", "D23", "西班牙語文學系", "西文系", "FL", 'D'],
          ["FJU", "D24", "日本語文學系", "日文系", "FL", 'D'],
          ["FJU", "D25", "義大利語文學系", "義文系", "FL", 'D'],
          ["FJU", "D26", "德語語文學系", "德語系", "FL", 'D'],
          # ["FJU", "",  "跨文化研究所", "跨文化研究所","", 'D'],

          ["FJU", "LH", "民生學院", "民生學院", nil, 'C'],
          ["FJU", "D43", "織品服裝學系", "織品服裝學系", "LH", 'D'],
          ["FJU", "D46", "織品服裝學系織品設計組", "織品服裝學系織品設計組", "LH", 'G'],
          ["FJU", "D48", "織品服裝學系織品服飾行銷組", "織品服裝學系織品服飾行銷組", "LH", 'G'],
          # ["FJU", "",  "織品服裝學研究所", "織品服裝學研究所","", 'D'],
          ["FJU", "D58", "兒童與家庭學系", "兒家系", "LH", 'D'],
          ["FJU", "G58", "兒童與家庭學研究所", "兒家所", "LH", 'D'],
          ["FJU", "D57", "餐旅管理學系", "餐旅系", "LH", 'D'],
          ["FJU", "G57", "餐旅管理學研究所", "餐旅所", "LH", 'D'],
          ["FJU", "D85", "食品科學系", "食科系", "LH", 'D'],
          ["FJU", "D86", "營養科學系", "營養系", "LH", 'D'],
          ["FJU", "G15", "博物館學研究所", "博物館學研究所", "LH", 'D'],
          # ["FJU", "",  "食品營養博士學位學程", "食品營養博士學位學程","", 'P'],
          # ["FJU", "",  "品牌與時尚經營管理碩士學位學程", "品牌與時尚經營管理碩士學位學程","", 'P'],

          ["FJU", "LA", "法律學院", "法律學院", nil, 'C'],
          ["FJU", "D66", "法律學系", "法律系", "LA", 'D'],
          ["FJU", "G66", "法律學研究所", "法律所", "LA", 'D'],
          ["FJU", "D67", "財經法律學系", "財法系", "LA", 'D'],
          ["FJU", "G67", "財經法律學研究所", "財法所", "LA", 'D'],
          # ["FJU", "",  "學士後法律學系", "學士後法律學系","", 'D'],

          ["FJU", "SC", "社會科學院", "社會科學院", nil, 'C'],
          ["FJU", "D63", "社會學系", "社會系", "SC", 'D'],
          ["FJU", "G63", "社會學系研究所", "社會所", "SC", 'D'],
          ["FJU", "D64", "社會工作學系", "社工系", "SC", 'D'],
          ["FJU", "G64", "社會工作學研究所", "社工所", "SC", 'D'],
          ["FJU", "D65", "經濟學系", "經濟系", "SC", 'D'],
          ["FJU", "G65", "經濟學研究所", "經濟所", "SC", 'D'],
          ["FJU", "D90", "宗教學系", "宗教系", "SC", 'D'],
          ["FJU", "G90", "宗教學研究所", "宗教所", "SC", 'D'],
          ["FJU", "D39", "心理學系", "心理系", "SC", 'D'],
          ["FJU", "G39", "心理學研究所", "心理所", "SC", 'D'],
          # ["FJU", "",  "天主教研修學士學位學程", "天主教研修學士學位學程","", 'P'],
          # ["FJU", "",  "非營利組織管理碩士學位學程", "非營利組織管理碩士學位學程","", 'P'],

          ["FJU", "MA", "管理學院", "管理學院", nil, 'C'],
          ["FJU", "D0E", "企業管理學系", "企管系", "MA", 'D'],
          ["FJU", "D71", "會計學系", "會計系", "MA", 'D'],
          ["FJU", "D76", "統計資訊學系", "統資系", "MA", 'D'],
          ["FJU", "D0F", "金融與國際企業學系", "金融國企系", "MA", 'D'],
          ["FJU", "D74", "資訊管理學系", "資管系", "MA", 'D'],
          ["FJU", "G77", "商學研究所", "商學研究所", "MA", 'D'],
          ["FJU", "G78", "科技管理碩士學位學程", "科技管理碩士學位學程", "MA", 'P'],
          ["FJU", "G79", "國際創業與經營管理碩士學位學程", "國際創業與經營管理碩士學位學程", "MA", 'P'],
          ["FJU", "G0N", "國際經營管理碩士班", "國際經營管理碩士班", "MA", 'P'],
          # ["FJU", "",  "商業管理學士學位學程", "商業管理學士學位學程","", 'P'],
          # ["FJU", "",  "社會企業碩士在職學位學程", "社會企業碩士在職學位學程","", 'P']
        ], :validate => false
      )

      if fju.email_patterns.count < 1
        create(:fju_student_email_pattern)
        create(:fju_staff_email_pattern)
      end
    end
  end

  factory :fju_student_email_pattern, parent: :email_pattern do
    priority 18
    organization { Organization.find_by(code: 'FJU') || create(:fju_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^(?<uid>(?<identity_detail>[4])(?<started_at>\\d{2}).{3,7})@mail\\.fju\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    identity_detail_postparser "switch (n.toLowerCase()) { case '4': 'day_division'; break; }"
    started_at_postparser "new Date((parseInt(n)+1911+100) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :fju_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'FJU') || create(:fju_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@mail\\.fju\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end
end
