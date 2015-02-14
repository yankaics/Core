FactoryGirl.define do
  factory :cycu_organization, parent: :organization do
    code 'CYCU'
    name '中原大學'
    short_name '中原'
    after(:create) do |cycu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [
          ["CYCU", "SC", "理學院", "理學院", nil, 'C'],
          ["CYCU", "EG", "工學院", "工學院", nil, 'C'],
          ["CYCU", "CM", "商學院", "商學院", nil, 'C'],
          ["CYCU", "DS", "設計學院", "設計學院", nil, 'C'],
          ["CYCU", "HE", "人文與教育學院", "人文與教育學院", nil, 'C'],
          ["CYCU", "LA", "法學院", "法學院", nil, 'C'],
          ["CYCU", "EE", "電機資訊學院", "電機資訊學院", nil, 'C'],
          ["CYCU", "ED", "師資培育中心", "師培中心", nil, 'D'],

          ["CYCU", "MA", "應用數學系", "應數系", "SC", 'D'],
          ["CYCU", "PH", "物理學系", "物理系", "SC", 'D'],
          ["CYCU", "CY", "化學系", "化學系", "SC", 'D'],
          ["CYCU", "PS", "心理學系", "心理系", "SC", 'D'],
          ["CYCU", "BT", "生物科技學系", "生科系", "SC", 'D'],
          ["CYCU", "NA", "奈米科技碩士學位學程", "奈米學位學程", "SC", 'P'],

          ["CYCU", "CH", "化學工程學系", "化工系", "EG", 'D'],
          ["CYCU", "CE", "土木工程學系", "土木系", "EG", 'D'],
          ["CYCU", "ME", "機械工程學系", "機械系", "EG", 'D'],
          ["CYCU", "BE", "生物醫學工程學系", "醫工系", "EG", 'D'],
          ["CYCU", "EB", "生物環境工程學系", "生環系", "EG", 'D'],

          ["CYCU", "BA", "企業管理學系", "企管系", "CM", 'D'],
          ["CYCU", "IT", "國際經營與貿易學系", "國貿系", "CM", 'D'],
          ["CYCU", "AC", "會計學系", "會計系", "CM", 'D'],
          ["CYCU", "MI", "資訊管理學系", "資管系", "CM", 'D'],
          ["CYCU", "FA", "財務金融學系", "財金系", "CM", 'D'],
          ["CYCU", "GM", "商學博士學位學程", "商學博", "CM", 'P'],
          ["CYCU", "BM", "國際商學碩士學位學程", "國際商碩", "CM", 'P'],

          ["CYCU", "AR", "建築學系", "建築系", "DS", 'D'],
          ["CYCU", "CD", "商業設計學系", "商設系", "DS", 'D'],
          ["CYCU", "ID", "室內設計學系", "室設系", "DS", 'D'],
          ["CYCU", "LA", "景觀學系", "景觀系", "DS", 'D'],
          ["CYCU", "PD", "設計學博士學位學程", "設計博", "DS", 'P'],
          ["CYCU", "DI", "設計學士原住民專班", "設計學士原住民專班", "DS", 'BC'],
          ["CYCU", "DM", "數音學位學程", "數音學位學程", "DS", "P"],

          ["CYCU", "SP", "特殊教育學系", "特教系", "HE", 'D'],
          ["CYCU", "LG", "應用外國語文學系", "應外系", "HE", 'D'],
          ["CYCU", "CL", "應用華語文學系", "應華系", "HE", 'D'],
          ["CYCU", "PR", "宗教研究所", "宗研所", "HE", 'D'],
          ["CYCU", "TA", "教育研究所", "教研所", "HE", 'D'],

          ["CYCU", "EF", "財經法律學系", "財法系", "LA", 'D'],

          ["CYCU", "IE", "工業與系統工程學系", "工業系", "EE", 'D'],
          ["CYCU", "EL", "電子工程學系", "電子系", "EE", 'D'],
          ["CYCU", "CS", "資訊工程學系", "資訊系", "EE", 'D'],
          ["CYCU", "EE", "電機工程學系", "電機系", "EE", 'D'],
          ["CYCU", "UP", "電機資訊學院學士班", "電資學院學士班", "EE", 'BC'],
          ["CYCU", "EC", "通訊工程碩士學位學程", "通訊碩士學位學程", "EE", 'P']
        ], :validate => false
      )

    end
  end
end
