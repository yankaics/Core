FactoryGirl.define do
  factory :cgu_organization, parent: :organization do
    code 'CGU'
    name '長庚大學'
    short_name '長庚'
    after(:create) do |cgu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [

          ["CGU", "SP", "體育室", "體育室", nil, 'U'],
          ["CGU", "SM", "軍訓教學組", "軍訓教學組", nil, 'U'],

          ["CGU", "M", "醫學院", "醫學院", nil, 'D'],
          ["CGU", "E", "工學院", "工學院", nil, 'D'],
          ["CGU", "MC", "管理學院", "管理學院", nil, 'D'],

          ["CGU", "MD",   "醫學系", "醫學系", "M", 'D'],
          ["CGU", "NS",   "護理系", "護理系", "M", 'D'],
          ["CGU", "NSM",  "護理學研究所碩士班", "護研所碩士班", "NS", 'MC'],
          ["CGU", "NSMJ", "護理學研究所碩士在職專班", "護研所碩士在職專班", "NS", 'JC'],

          ["CGU", "MT",   "生技系", "生技系", "M", 'D'],
          ["CGU", "MTM",  "生技系碩士班", "生技系碩士班", "MT", 'MC'],
          ["CGU", "PT",   "物理治療系", "物治系", "M", 'D'],
          ["CGU", "RSM",  "物理治療系復科碩士班", "物治系復科碩士班", "PT", 'MC'],
          ["CGU", "RSD",  "物理治療系復科博士班", "物治系復科博士班", "PT", 'DC'],

          ["CGU", "OT",   "職能治療系", "職治系", "M", 'D'],
          ["CGU", "BSM",  "職能治療系臨行碩士班", "職治系臨行碩士班", "OT", 'MC'],
          ["CGU", "BSM1", "職能治療系臨行心理碩士班", "職治系臨行心理碩士班", "OT", 'G'],
          ["CGU", "BSM2", "職能治療系臨行職治碩士班", "職治系臨行職治碩士班", "OT", 'G'],

          ["CGU", "TM",  "中醫系", "中醫系", "M", 'D'],
          ["CGU", "NPM", "中醫學系傳統中醫學碩士班", "中醫系天藥碩士班", "TM", 'MC'],
          ["CGU", "TMM", "中醫學系天然藥物碩士班", "中醫系傳醫碩士班", "TM", 'MC'],
          ["CGU", "RT",  "呼吸治療系", "呼治系", "M", 'D'],
          ["CGU", "LS",  "生醫系", "生醫系", "M", 'D'],
          ["CGU", "RS",  "醫學影像暨放射科學系", "醫放系", "M", 'D'],
          ["CGU", "MPM", "醫放系碩士班", "醫放系碩士班", "MC", 'D'],

          ["CGU", "CM",   "臨床醫學研究所", "臨醫所", "M", 'D'],
          ["CGU", "CMD",  "臨床醫學研究所博士班", "臨床醫學研究所博士班", "CM", 'DC'],
          ["CGU", "CMD1", "臨醫所博士班臨醫組", "臨醫所博士班臨醫組", "CMD", 'G'],
          ["CGU", "CMD2", "臨醫所博士班護理組", "臨醫所博士班護理組", "CMD", 'G'],
          ["CGU", "CMD3", "臨醫所博士班中醫組", "臨醫所博士班中醫組", "CMD", 'G'],
          ["CGU", "CMD4", "臨醫所博士班醫放組", "臨醫所博士班醫放組", "CMD", 'G'],
          ["CGU", "CMM",  "臨床醫學研究所碩士班", "臨床醫學研究所碩士班", "CM", 'MC'],
          ["CGU", "CMM1", "臨醫所碩士班呼照組", "臨醫所碩士班呼照組", "CMM", 'G'],
          ["CGU", "CMM2", "臨醫所碩士班臨醫組", "臨醫所碩士班臨醫組", "CMM", 'G'],
          ["CGU", "CMM3", "臨醫所碩士班臨資組", "臨醫所碩士班臨資組", "CMM", 'G'],
          ["CGU", "CMM4", "臨醫所碩士班醫教組", "臨醫所碩士班醫教組", "CMM", 'G'],

          ["CGU", "BM",   "生物醫學系", "生物醫學系", "M", 'D'],
          ["CGU", "BMI",   "生物醫學所", "生物醫學所", "M", 'D'],
          ["CGU", "BMD",  "生物醫學所博士班", "生物醫學所博士班", "BMI", 'DC'],
          ["CGU", "BMD1", "生醫所博士班生化組", "生醫所博士班生化組", "BMD", 'G'],
          ["CGU", "BMD2", "生醫所博士班微生物組", "生醫所博士班微生物組", "BMD", 'G'],
          ["CGU", "BMD3", "生醫所博士班生藥理組", "生醫所博士班生藥理組", "BMD", 'G'],
          ["CGU", "BMD4", "生醫所博士班生技組", "生醫所博士班生技組", "BMD", 'G'],
          ["CGU", "BMD5", "生醫所博士班天藥組", "生醫所博士班天藥組", "BMD", 'G'],
          ["CGU", "BME", "生化與生醫工程研究所", "生化與生醫工程研究所", "M", 'D'],
          ["CGU", "BMEP", "生物醫學工程博士學程", "生醫博士學程", "BMD", 'P'],
          ["CGU", "BMM",  "生物醫學所碩士班", "生物醫學所碩士班", "BM", 'D'],
          ["CGU", "BMM1", "生醫所碩士班生化組", "生醫所碩士班生化組", "BMM", 'G'],
          ["CGU", "BMM2", "生醫所碩士班微生物組", "生醫所碩士班微生物組", "BMM", 'G'],
          ["CGU", "BMM3", "生醫所碩士班生藥理組", "生醫所碩士班生藥理組", "BMM", 'G'],

          ["CGU", "MHS", "人文及社會醫學科", "人文及社會醫學科", "M", 'D'],
          ["CGU", "PR", "公共衛生暨寄生蟲學科", "公衛暨寄生蟲學科", "M", 'D'],
          ["CGU", "DMI", "微生物及免疫學科", "微生物及免疫學科", "M", 'D'],
          ["CGU", "BMB", "生化暨分子生物學科", "生化暨分子生物學科", "M", 'D'],
          ["CGU", "DOP", "生理暨藥理學科", "生理暨藥理學科", "M", 'D'],
          ["CGU", "PA", "病理學科", "病理學科", "M", 'D'],
          ["CGU", "AT", "解剖學科", "解剖學科", "M", 'D'],
          ["CGU", "MIP", "醫學生物技術暨檢驗學系", "醫檢系", "M", 'D'],
          ["CGU", "GPMM", "分子醫學全英語碩士學位學程", "分子醫學全英語碩士學位學程", "M", 'P'],

          ["CGU", "CD", "顱顏口腔醫學研究所", "顱顏口腔研究所", "M", 'D'],
          ["CGU", "CDM", "顱顏所碩士班", "顱顏所碩士班", "CD", 'MC'],
          ["CGU", "EI", "早期療育研究所", "早療所", "M", 'D'],
          ["CGU", "EIM", "早期療育研究所碩士班", "早療所碩士班", "EI", 'MC'],


          ["CGU", "EE", "電機工程系", "電機系", "E", 'D'],
          ["CGU", "EE1", "電機系通訊組", "電機系通訊組", "EE", 'G'],
          ["CGU", "EE2", "電機系系統組", "電機系系統組", "EE", 'G'],
          ["CGU", "EED", "電機系博士班", "電機系博士班", "EE", 'DC'],
          ["CGU", "EEM", "電機系碩士班", "電機系碩士班", "EE", 'MC'],
          ["CGU", "EEMJ", "電機系碩士在職班", "電機系碩士在職班", "EE", 'JC'],

          ["CGU", "ME", "機械系", "機械系", "E", 'D'],
          ["CGU", "MED", "機械系博士班", "機械系博士班", "ME", 'MC'],
          ["CGU", "MEM", "機械系碩士班", "機械系碩士班", "ME", 'DC'],

          ["CGU", "CE", "化工與材料工程學系", "化材系", "E", 'D'],
          ["CGU", "CED", "化工與材料工程學系博士班", "化材系博士班", "CE", 'DC'],
          ["CGU", "CEM", "化工與材料工程學系碩士班", "化材系碩士班", "CE", 'MC'],
          ["CGU", "CEMJ", "化工與材料工程學系碩士在職班", "化材系碩士在職班", "CE", 'JC'],

          ["CGU", "EN", "電子工程系", "電子系", "E", 'D'],
          ["CGU", "END", "電子系博士班", "電子系博士班", "EN", 'DC'],
          ["CGU", "ENM", "電子系碩士班", "電子系碩士班", "EN", 'MC'],
          ["CGU", "ENM", "電子系碩士在職班", "電子系碩士在職班", "EN", 'JC'],

          ["CGU", "OE", "光電工程研究所", "光電所", "E", 'D'],
          ["CGU", "OEM", "光電工程研究所碩士班", "光電所碩士班", "OE", 'D'],

          ["CGU", "MM", "醫療機電工程研究所", "醫電所", "E", 'D'],
          ["CGU", "MMM", "醫療機電所碩士班", "醫療機電所碩士班", "MM", 'MC'],

          ["CGU", "BE", "生化生醫所", "生化生醫所", "E", 'D'],
          ["CGU", "BEM", "生化生醫所碩士班", "生化生醫所碩士班", "BE", 'MC'],

          ["CGU", "IT", "資訊工程系", "資工系", "E", 'D'],
          ["CGU", "ITM", "資工系碩士班", "資工系碩士班", "IT", 'MC'],

          ["CGU", "BID", "醫工博士學程", "醫工博士學程", "E", 'P'],

          ["CGU", "MCM", "管理學院碩士", "管理學院碩士", "MC", 'MC'],

          ["CGU", "HM", "醫務管理系", "醫管系", "MC", 'D'],
          ["CGU", "HMM", "醫管系碩士班", "醫管系碩士班", "HM", 'D'],

          ["CGU", "BS", "工商管理學系", "工商系", "MC", 'D'],
          ["CGU", "BSM", "工商系碩士班", "工商系碩士班", "BS", 'MC'],

          ["CGU", "ID", "工業設計學系", "工設系", "MC", 'D'],
          ["CGU", "ID1", "工設系產設組", "工設系產設組", "ID", 'G'],
          ["CGU", "ID2", "工設系媒傳組", "工設系媒傳組", "ID", 'G'],
          ["CGU", "IDM", "工設系碩士班", "工設系碩士班", "ID", 'MC'],

          ["CGU", "BA", "企業管理研究所", "企業管理研究所", "MC", 'D'],
          ["CGU", "BAD", "企業管理研究所博士班", "企管所博士班", "BA", 'DC'],

          ["CGU", "IM", "資訊管理系", "資管系", "MC", 'D'],
          ["CGU", "IMM", "資管系碩士班", "資管系碩士班", "IM", 'MC'],

          ["CGU", "SB", "商管專業學院", "專業學院", "MC", 'D'],
          ["CGU", "SBM", "商管專業學院碩士學分班", "專業學院碩士班", "SB", 'MC'],
          ["CGU", "SBM1", "商管碩士在職醫管組", "商管碩士在職醫管組", "SB", 'G'],
          ["CGU", "SBM2", "商管碩士在職資管組", "商管碩士在職資管組", "SB", 'G'],
          ["CGU", "SBM3", "商管碩士在職經管組", "商管碩士在職經管組", "SB", 'G'],

          ["CGU", "G", "通識中心", "通識中心", nil, 'U']
        ], :validate => false
      )

      if cgu.email_patterns.count < 1
        create(:cgu_student_email_pattern)
        create(:cgu_staff_email_pattern)
      end
    end
  end

  factory :cgu_student_email_pattern, parent: :email_pattern do
    priority 15
    organization { Organization.find_by(code: 'CGU') || create(:cgu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^(?<uid>(?<identity_detail>[aAbmdBMD])(?<started_at>\\d{2})\\d{2,12})@stmail\\.cgu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    identity_detail_postparser "switch (n.toLowerCase()) { case 'a': 'a'; break; case 'b': 'bachelor'; break; case 'm': 'master'; break; case 'd': 'doctor'; break; }"
    started_at_postparser "new Date((parseInt(n)+1911+100) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :cgu_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'CGU') || create(:cgu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@mail\\.cgu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end
end
