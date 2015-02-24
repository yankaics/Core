FactoryGirl.define do
  factory :ntpu_organization, parent: :organization do
    code 'NTPU'
    name '國立臺北大學'
    short_name '北大'
    after(:create) do |ntpu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [

          ["NTPU", "00", "法律學院", "法律學院", nil, 'C'],
          ["NTPU", "01", "商學院", "商學院", nil, 'C'],
          ["NTPU", "02", "公共事務學院", "公務學院", nil, 'C'],
          ["NTPU", "03", "社會科學學院", "社科學院", nil, 'C'],
          ["NTPU", "04", "人文學院", "人文學院", nil, 'C'],
          ["NTPU", "05", "電機資訊學院", "電資學院", nil, 'C'],
          ["NTPU", "06", "通識教育中心", "通識教育中心", nil, 'C'],
          ["NTPU", "07", "亞洲研究中心", "亞洲研究中心", nil, 'C'],

          ["NTPU", "0000", "法律學系", "法律系", "00", "D"],
          ["NTPU", "0001", "比較法資料中心", "比較法資料中心", "00", "D"],

          ["NTPU", "0100", "企業管理學系", "企管系", "01", "D"],
          ["NTPU", "0101", "金融與合作經營學系", "金融與合作經營學系", "01", "D"],
          ["NTPU", "0102", "會計學系", "會計系", "01", "D"],
          ["NTPU", "0103", "統計學系", "統計系", "01", "D"],
          ["NTPU", "0104", "休閒運動與管理學系", "休閒運動與管理學系", "01", "D"],
          ["NTPU", "0105", "資訊管理研究所", "資管所", "01", "D"],
          ["NTPU", "0106", "電子商務研究中心", "電子商務研究中心", "01", "D"],
          ["NTPU", "0107", "合作經濟暨非營利事業研究中心", "合作經濟暨非營利事業研究中心", "01", "D"],
          ["NTPU", "0108", "國際財務金融碩士在職專班(IEMBA)", "國際財務金融碩士在職專班(IEMBA)", "01", "D"],
          ["NTPU", "0109", "國際企業研究所", "國際企業研究所", "01", "D"],
          ["NTPU", "0110", "AACSB商學認證辦公室", "AACSB商學認證辦公室", "01", "D"],

          ["NTPU", "0200", "公共行政暨政策學系", "公共行政暨政策學系", "02", "D"],
          ["NTPU", "0201", "財政學系", "財政學系", "02", "D"],
          ["NTPU", "0202", "不動產與城鄉學系", "不動產與城鄉學系", "02", "D"],
          ["NTPU", "0203", "都市計畫研究所", "都市計畫研究所", "02", "D"],
          ["NTPU", "0204", "自然資源與環境管理研究所", "自然資源與環境管理研究所", "02", "D"],
          ["NTPU", "0205", "民意與選舉研究中心", "民意與選舉研究中心", "02", "D"],
          ["NTPU", "0206", "土地與環境規劃研究中心", "土地與環境規劃研究中心", "02", "D"],

          ["NTPU", "0300", "經濟學系", "經濟系", "03", "D"],
          ["NTPU", "0301", "社會學系", "社會系", "03", "D"],
          ["NTPU", "0302", "社會工作學系", "社會工作學系", "03", "D"],
          ["NTPU", "0303", "犯罪學研究所", "犯罪學研究所", "03", "D"],
          ["NTPU", "0304", "台灣發展研究中心", "台灣發展研究中心", "03", "D"],

          ["NTPU", "0400", "中國文學系", "中文系", "04", "D"],
          ["NTPU", "0401", "應用外語學系", "應外系", "04", "D"],
          ["NTPU", "0402", "歷史學系", "歷史系", "04", "D"],
          ["NTPU", "0403", "古典文獻與民俗藝術研究所", "古典文獻與民俗藝術研究所", "04", "D"],
          ["NTPU", "0404", "師資培育中心", "師培中心", "04", "D"],
          ["NTPU", "0405", "國際談判及同步翻譯中心", "國際談判及同步翻譯中心", "04", "D"],
          ["NTPU", "0406", "東西哲學與詮釋學研究中心", "東西哲學與詮釋學研究中心", "04", "D"],

          ["NTPU", "0500", "資訊工程學系", "資工系", "05", "D"],
          ["NTPU", "0501", "通訊工程研究所", "通訊工程研究所", "05", "D"],
          ["NTPU", "0502", "電機工程研究所", "電機工程研究", "05", "D"]

        ], :validate => false
      )

      if ntpu.email_patterns.count < 1
        create(:ntpu_student_email_pattern_1)
        create(:ntpu_student_email_pattern_2)
        create(:ntpu_staff_email_pattern)
      end
    end
  end

  factory :ntpu_student_email_pattern_1, parent: :email_pattern do
    priority 10
    organization { Organization.find_by(code: 'NTPU') || create(:ntpu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^s(?<uid>(?<identity_detail>\\d)(?<started_at>\\d{3})(?<department_code>\\d{2})\\d{1,5})@webmail\\.ntpu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :ntpu_student_email_pattern_2, parent: :email_pattern do
    priority 11
    organization { Organization.find_by(code: 'NTPU') || create(:ntpu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^s(?<uid>.+)@webmail\\.ntpu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :ntpu_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'NTPU') || create(:ntpu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@webmail\\.ntpu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end

  factory :ntpu_student_email_pattern_1_2, parent: :email_pattern do
    priority 12
    organization { Organization.find_by(code: 'NTPU') || create(:ntpu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^s(?<uid>(?<identity_detail>\\d)(?<started_at>\\d{3})(?<department_code>\\d{2})\\d{1,5})@\\w{1,5}\\.ntpu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :ntpu_student_email_pattern_2_2, parent: :email_pattern do
    priority 13
    organization { Organization.find_by(code: 'NTPU') || create(:ntpu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^s(?<uid>.+)@\\w{1,5}\\.ntpu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :ntpu_staff_email_pattern_2, parent: :email_pattern do
    priority 101
    organization { Organization.find_by(code: 'NTPU') || create(:ntpu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@\\w{1,5}\\.ntpu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end
end
