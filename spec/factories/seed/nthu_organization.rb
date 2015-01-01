FactoryGirl.define do
  factory :nthu_organization, parent: :organization do
    code 'NTHU'
    name '國立清華大學'
    short_name '清大'
    after(:create) do |nthu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [

          ["NTHU", "00", "跨院系所", "跨院系所", nil, 'C'],
          ["NTHU", "01", "原子科學院", "原子科學院", nil, 'C'],
          ["NTHU", "02", "理學院", "理學院", nil, 'C'],
          ["NTHU", "03", "工學院", "工學院", nil, 'C'],
          ["NTHU", "04", "人文社會學院", "人文社會學院", nil, 'C'],
          ["NTHU", "06", "電機資訊學院", "電機資訊學院", nil, 'C'],
          ["NTHU", "07", "科技管理學院", "科技管理學院", nil, 'C'],
          ["NTHU", "08", "生命科學院", "生命科學院", nil, 'C'],

          ["NTHU", "000", "跨系所", "跨系所", "00", 'D'],
          ["NTHU", "001", "先進光源科技學位學程", "先進光源科技學位學程", "00", 'D'],
          ["NTHU", "002", "學習科學研究所", "學習科學研究所", "00", 'D'],
          ["NTHU", "010", "原科院學士班", "原科院學士班", "01", 'D'],
          ["NTHU", "011", "工程與系統科學系", "工程與系統科學系", "01", 'D'],
          ["NTHU", "012", "生醫工程與環境科學系", "生醫工程與環境科學系", "01", 'D'],
          ["NTHU", "013", "核子工程與科學研究所", "核子工程與科學研究所", "01", 'D'],
          ["NTHU", "020", "理學院跨系所", "理學院跨系所", "02", 'D'],
          ["NTHU", "021", "數學系", "數學系", "02", 'D'],
          ["NTHU", "022", "物理學系", "物理學系", "02", 'D'],
          ["NTHU", "023", "化學系", "化學系", "02", 'D'],
          ["NTHU", "024", "統計學研究所", "統計學研究所", "02", 'D'],
          ["NTHU", "025", "天文研究所", "天文研究所", "02", 'D'],
          ["NTHU", "030", "工學院跨系所", "工學院跨系所", "03", 'D'],
          ["NTHU", "031", "材料科學工程學系", "材料科學工程學系", "03", 'D'],
          ["NTHU", "032", "化學工程學系", "化學工程學系", "03", 'D'],
          ["NTHU", "033", "動力機械工程學系", "動力機械工程學系", "03", 'D'],
          ["NTHU", "034", "工業工程與工程管理學系", "工業工程與工程管理學系", "03", 'D'],
          ["NTHU", "035", "奈米工程與微系統研究所", "奈米工程與微系統研究所", "03", 'D'],
          ["NTHU", "036", "工業工程與工程管理學系在職專班", "工業工程與工程管理學系在職專班", "03", 'D'],
          ["NTHU", "037", "工學院光電產業專班", "工學院光電產業專班", "03", 'D'],
          ["NTHU", "038", "生物醫學工程研究所", "生物醫學工程研究所", "03", 'D'],
          ["NTHU", "040", "跨系所招生", "跨系所招生", "04", 'D'],
          ["NTHU", "041", "中國文學系", "中國文學系", "04", 'D'],
          ["NTHU", "042", "外國語文學系", "外國語文學系", "04", 'D'],
          ["NTHU", "043", "歷史研究所", "歷史研究所", "04", 'D'],
          ["NTHU", "044", "語言學研究所", "語言學研究所", "04", 'D'],
          ["NTHU", "045", "社會學研究所", "社會學研究所", "04", 'D'],
          ["NTHU", "046", "人類學研究所", "人類學研究所", "04", 'D'],
          ["NTHU", "047", "哲學研究所", "哲學研究所", "04", 'D'],
          ["NTHU", "048", "人文社會學院學士班", "人文社會學院學士班", "04", 'D'],
          ["NTHU", "049", "台灣文學研究所", "台灣文學研究所", "04", 'D'],
          ["NTHU", "141", "台灣教師在職進修專班", "台灣教師在職進修專班", "04", 'D'],
          ["NTHU", "142", "亞際文化研究碩士學位國際學程", "亞際文化研究碩士學位國際學程", "04", 'D'],
          ["NTHU", "060", "電機資訊學院學士班", "電機資訊學院學士班", "06", 'D'],
          ["NTHU", "061", "電機工程學系", "電機工程學系", "06", 'D'],
          ["NTHU", "062", "資訊工程學系", "資訊工程學系", "06", 'D'],
          ["NTHU", "063", "電子工程研究所", "電子工程研究所", "06", 'D'],
          ["NTHU", "064", "通訊工程研究所", "通訊工程研究所", "06", 'D'],
          ["NTHU", "065", "資訊系統與應用研究所", "資訊系統與應用研究所", "06", 'D'],
          ["NTHU", "066", "光電工程研究所", "光電工程研究所", "06", 'D'],
          ["NTHU", "067", "電資院積體電路產業專班", "電資院積體電路產業專班", "06", 'D'],
          ["NTHU", "068", "電資院半導體元件及製程專班", "電資院半導體元件及製程專班", "06", 'D'],
          ["NTHU", "069", "電資院電力電子專班", "電資院電力電子專班", "06", 'D'],
          ["NTHU", "161", "光電博士學位學程", "光電博士學位學程", "06", 'D'],
          ["NTHU", "162", "社群網路與人智計算國際研究生博士學位學程", "社群網路與人智計算國際研究生博士學位學程", "06", 'D'],
          ["NTHU", "070", "科技管理學院學士班", "科技管理學院學士班", "07", 'D'],
          ["NTHU", "071", "計量財務金融系", "計量財務金融系", "07", 'D'],
          ["NTHU", "072", "經濟學系", "經濟學系", "07", 'D'],
          ["NTHU", "073", "科技管理研究所", "科技管理研究所", "07", 'D'],
          ["NTHU", "074", "科技法律研究所", "科技法律研究所", "07", 'D'],
          ["NTHU", "075", "高階經營管理碩士在職專班", "高階經營管理碩士在職專班", "07", 'D'],
          ["NTHU", "076", "經營管理碩士在職專班", "經營管理碩士在職專班", "07", 'D'],
          ["NTHU", "077", "國際專業管理碩士班", "國際專業管理碩士班", "07", 'D'],
          ["NTHU", "078", "服務科學研究所", "服務科學研究所", "07", 'D'],
          ["NTHU", "080", "生命科學院學士班", "生命科學院學士班", "08", 'D'],
          ["NTHU", "081", "生命科學系", "生命科學系", "08", 'D'],
          ["NTHU", "082", "醫學科學系", "醫學科學系", "08", 'D'],
          ["NTHU", "083", "跨領域神經科學博士學位學程", "跨領域神經科學博士學位學程", "08", 'D'],

          ["NTHU", "0000", "跨系學士班", "跨系學士班", "000", 'BC'],
          ["NTHU", "0008", "跨系博士班", "跨系博士班", "000", 'DC'],
          ["NTHU", "0015", "先進光源科技學位學程", "先進光源科技學位學程物理組碩士班", "001", 'MC'],
          ["NTHU", "0016", "先進光源科技學位學程", "先進光源科技學位學程工科組碩士班", "001", 'MC'],
          ["NTHU", "0018", "先進光源科技學位學程", "先進光源科技學位學程博士班", "001", 'DC'],
          ["NTHU", "0025", "學習科學研究所", "學習科學研究所碩士班", "002", 'MC'],
          ["NTHU", "0100", "原科院學士班", "原科院學士班", "010", 'BC'],
          ["NTHU", "0111", "工程與系統科學系", "工程與系統科學系清班", "011", 'BC'],
          ["NTHU", "0112", "工程與系統科學系", "工程與系統科學系華班", "011", 'BC'],
          ["NTHU", "0115", "工程與系統科學系", "工程與系統科學系碩士班", "011", 'MC'],
          ["NTHU", "0118", "工程與系統科學系", "工程與系統科學系博士班", "011", 'DC'],
          ["NTHU", "0120", "生醫工程與環境科學系", "生醫工程與環境科學系學士班", "012", 'BC'],
          ["NTHU", "0125", "生醫工程與環境科學系", "生醫工程與環境科學系碩士班", "012", 'MC'],
          ["NTHU", "0128", "生醫工程與環境科學系", "生醫工程與環境科學系博士班", "012", 'DC'],
          ["NTHU", "0135", "核子工程與科學研究所", "核子工程與科學研究所碩士班", "013", 'MC'],
          ["NTHU", "0138", "核子工程與科學研究所", "核子工程與科學研究所博士班", "013", 'DC'],
          ["NTHU", "0200", "理學院學士班", "理學院學士班", "020", 'BC'],
          ["NTHU", "0208", "理學院博士班", "理學院博士班", "020", 'DC'],
          ["NTHU", "0212", "數學系純粹數學組", "數學系純粹數學組學士班", "021", 'BC'],
          ["NTHU", "0211", "數學系應用數學組", "數學系應用數學組學士班", "021", 'BC'],
          ["NTHU", "0215", "數學系純粹數學組", "數學系純粹數學組碩士班", "021", 'MC'],
          ["NTHU", "0216", "數學系應用數學組", "數學系應用數學組碩士班", "021", 'MC'],
          ["NTHU", "0218", "數學系博士班", "數學系博士班", "021", 'DC'],
          ["NTHU", "0221", "物理學系物理組", "物理學系物理組學士班", "022", 'BC'],
          ["NTHU", "0222", "物理學系光電物理組", "物理學系光電物理組學士班", "022", 'BC'],
          ["NTHU", "0225", "物理學系", "物理學系碩士班", "022", 'MC'],
          ["NTHU", "0228", "物理學系", "物理學系博士班", "022", 'DC'],
          ["NTHU", "0230", "化學系", "化學系學士班", "023", 'BC'],
          ["NTHU", "0235", "化學系化學組", "化學系化學組碩士班", "023", 'MC'],
          ["NTHU", "0236", "化學系應用化學組", "化學系應用化學組碩士班", "023", 'MC'],
          ["NTHU", "0238", "化學系", "化學系博士班", "023", 'DC'],
          ["NTHU", "0245", "統計學研究所", "統計學研究所碩士班", "024", 'MC'],
          ["NTHU", "0248", "統計學研究所", "統計學研究所博士班", "024", 'DC'],
          ["NTHU", "0255", "天文研究所", "天文研究所碩士班", "025", 'MC'],
          ["NTHU", "0258", "天文研究所", "天文研究所博士班", "025", 'DC'],
          ["NTHU", "0300", "工學院學士班", "工學院學士班", "030", 'BC'],
          ["NTHU", "0305", "工學院生物工程學程", "工學院生物工程學程碩士班", "030", 'MC'],
          ["NTHU", "0306", "工學院分子工程學程", "工學院分子工程學程碩士班", "030", 'MC'],
          ["NTHU", "0311", "材料科學工程學系清班", "材料科學工程學系學士清班", "031", 'BC'],
          ["NTHU", "0312", "材料科學工程學系華班", "材料科學工程學系學士華班", "031", 'BC'],
          ["NTHU", "0315", "材料科學工程學系", "材料科學工程學系碩士班", "031", 'MC'],
          ["NTHU", "0316", "材料科學工程學系", "材料科學工程學系碩士班", "031", 'MC'],
          ["NTHU", "0318", "材料科學工程學系", "材料科學工程學系博士班", "031", 'DC'],
          ["NTHU", "0320", "化學工程學系", "化學工程學系學士班", "032", 'BC'],
          ["NTHU", "0325", "化學工程學系", "化學工程學系碩士班", "032", 'MC'],
          ["NTHU", "0328", "化學工程學系", "化學工程學系博士班", "032", 'DC'],
          ["NTHU", "0331", "動力機械工程學系清班", "動力機械工程學系學士清班", "033", 'BC'],
          ["NTHU", "0332", "動力機械工程學系華班", "動力機械工程學系學士華班", "033", 'BC'],
          ["NTHU", "0335", "動力機械工程學系", "動力機械工程學系碩士班", "033", 'MC'],
          ["NTHU", "0336", "動力機械工程學系", "動力機械工程學系碩士班", "033", 'MC'],
          ["NTHU", "0338", "動力機械工程學系", "動力機械工程學系博士班", "033", 'DC'],
          ["NTHU", "0340", "工業工程與工程管理學系", "工業工程與工程管理學系學士班", "034", 'BC'],
          ["NTHU", "0345", "工業工程與工程管理學系工業工程組", "工業工程與工程管理學系工業工程組碩士班", "034", 'MC'],
          ["NTHU", "0346", "工業工程與工程管理學系工程管理組", "工業工程與工程管理學系工程管理組碩士班", "034", 'MC'],
          ["NTHU", "0348", "工業工程與工程管理學系", "工業工程與工程管理學系博士班", "034", 'DC'],
          ["NTHU", "0355", "奈米工程與微系統研究所", "奈米工程與微系統研究所碩士班", "035", 'MC'],
          ["NTHU", "0358", "奈米工程與微系統研究所", "奈米工程與微系統研究所博士班", "035", 'DC'],
          ["NTHU", "0365", "工業工程與工程管理學系在職專班", "工業工程與工程管理學系在職專班", "036", 'MC'],
          ["NTHU", "0375", "工學院光電產業專班", "工學院光電產業專班", "037", 'MC'],
          ["NTHU", "0385", "生物醫學工程研究所", "生物醫學工程研究所碩士班", "038", 'MC'],
          ["NTHU", "0410", "中國文學系", "中國文學系學士班", "041", 'BC'],
          ["NTHU", "0415", "中國文學系", "中國文學系碩士班", "041", 'MC'],
          ["NTHU", "0418", "中國文學系", "中國文學系博士班", "041", 'DC'],
          ["NTHU", "0420", "外國語文學系", "外國語文學系學士班", "042", 'BC'],
          ["NTHU", "0425", "外國語文學系", "外國語文學系碩士班", "042", 'MC'],
          ["NTHU", "0426", "外國語文學系外語教學組", "外國語文學系外語教學組碩士班", "042", 'MC'],
          ["NTHU", "0435", "歷史研究所", "歷史研究所碩士班", "043", 'MC'],
          ["NTHU", "0438", "歷史研究所", "歷史研究所博士班", "043", 'DC'],
          ["NTHU", "0436", "歷史研究所中研院合作學程", "歷史研究所中研院合作學程碩士班", "043", 'MC'],
          ["NTHU", "0445", "語言學研究所", "語言學研究所碩士班", "044", 'MC'],
          ["NTHU", "0448", "語言學研究所", "語言學研究所博士班", "044", 'DC'],
          ["NTHU", "0455", "社會學研究所", "社會學研究所碩士班", "045", 'MC'],
          ["NTHU", "0458", "社會學研究所", "社會學研究所博士班", "045", 'DC'],
          ["NTHU", "0456", "社會學研究所中研院合作學程", "社會學研究所中研院合作學程碩士班", "045", 'MC'],
          ["NTHU", "0465", "人類學研究所", "人類學研究所碩士班", "046", 'MC'],
          ["NTHU", "0468", "人類學研究所", "人類學研究所博士班", "046", 'DC'],
          ["NTHU", "0475", "哲學研究所", "哲學研究所碩士班", "047", 'MC'],
          ["NTHU", "0481", "人文社會學院清班", "人文社會學院學士清班", "048", 'BC'],
          ["NTHU", "0482", "人文社會學院華班", "人文社會學院學士華班", "048", 'BC'],
          ["NTHU", "0495", "台灣文學研究所", "台灣文學研究所碩士班", "049", 'MC'],
          ["NTHU", "0498", "台灣文學研究所", "台灣文學研究所博士班", "049", 'DC'],
          ["NTHU", "1415", "台灣教師在職進修專班", "台灣教師在職進修專班", "141", 'MC'],
          ["NTHU", "1425", "亞際文化研究碩士學位國際學程", "亞際文化研究碩士學位國際學程", "142", 'MC'],
          ["NTHU", "0600", "電機資訊學院", "電機資訊學院學士班", "060", 'BC'],
          ["NTHU", "0611", "電機工程學系清班", "電機工程學系學士清班", "061", 'BC'],
          ["NTHU", "0612", "電機工程學系華班", "電機工程學系學士華班", "061", 'BC'],
          ["NTHU", "0615", "電機工程學系", "電機工程學系碩士班", "061", 'MC'],
          ["NTHU", "0616", "電機工程學系", "電機工程學系碩士班", "061", 'MC'],
          ["NTHU", "0618", "電機工程學系", "電機工程學系博士班", "061", 'DC'],
          ["NTHU", "0621", "資訊工程學系清班", "資訊工程學系學士清班", "062", 'BC'],
          ["NTHU", "0622", "資訊工程學系華班", "資訊工程學系學士華班", "062", 'BC'],
          ["NTHU", "0623", "資訊工程學系梅班", "資訊工程學系學士梅班", "062", 'BC'],
          ["NTHU", "0625", "資訊工程學系", "資訊工程學系碩士班", "062", 'MC'],
          ["NTHU", "0626", "資訊工程學系", "資訊工程學系碩士班", "062", 'MC'],
          ["NTHU", "0628", "資訊工程學系", "資訊工程學系博士班", "062", 'DC'],
          ["NTHU", "0635", "電子工程研究所", "電子工程研究所碩士班", "063", 'MC'],
          ["NTHU", "0638", "電子工程研究所", "電子工程研究所博士班", "063", 'DC'],
          ["NTHU", "0645", "通訊工程研究所", "通訊工程研究所碩士班", "064", 'MC'],
          ["NTHU", "0648", "通訊工程研究所", "通訊工程研究所博士班", "064", 'DC'],
          ["NTHU", "0655", "資訊系統與應用研究所", "資訊系統與應用研究所碩士班", "065", 'MC'],
          ["NTHU", "0658", "資訊系統與應用研究所", "資訊系統與應用研究所博士班", "065", 'DC'],
          ["NTHU", "0656", "資訊系統與應用研究所", "資訊系統與應用研究所碩士班", "065", 'MC'],
          ["NTHU", "0665", "光電工程研究所", "光電工程研究所碩士班", "066", 'MC'],
          ["NTHU", "0668", "光電工程研究所", "光電工程研究所博士班", "066", 'DC'],
          ["NTHU", "0675", "電資院積體電路產業專班", "電資院積體電路產業專班", "067", 'MC'],
          ["NTHU", "0685", "電資院半導體元件及製程專班", "電資院半導體元件及製程專班", "068", 'MC'],
          ["NTHU", "0695", "電資院電力電子專班", "電資院電力電子專班", "069", 'MC'],
          ["NTHU", "1618", "光電博士學位學程", "光電博士學位學程", "161", 'DC'],
          ["NTHU", "1628", "社群網路與人智計算國際研究生博士學位學程", "社群網路與人智計算國際研究生博士學位學程", "162", 'DC'],
          ["NTHU", "0700", "科技管理學院", "科技管理學院學士班", "070", 'BC'],
          ["NTHU", "0710", "計量財務金融系", "計量財務金融系學士班", "071", 'BC'],
          ["NTHU", "0715", "計量財務金融系", "計量財務金融系碩士班", "071", 'MC'],
          ["NTHU", "0721", "經濟學系清班", "經濟學系學士清班", "072", 'BC'],
          ["NTHU", "0722", "經濟學系華班", "經濟學系學士華班", "072", 'BC'],
          ["NTHU", "0725", "經濟學系", "經濟學系碩士班", "072", 'MC'],
          ["NTHU", "0728", "經濟學系", "經濟學系博士班", "072", 'DC'],
          ["NTHU", "0735", "科技管理研究所", "科技管理研究所碩士班", "073", 'MC'],
          ["NTHU", "0738", "科技管理研究所", "科技管理研究所博士班", "073", 'DC'],
          ["NTHU", "0745", "科技法律研究所科技組", "科技法律研究所科技組碩士班", "074", 'MC'],
          ["NTHU", "0746", "科技法律研究所一般法律組", "科技法律研究所一般法律組碩士班", "074", 'MC'],
          ["NTHU", "0755", "高階經營管理碩士在職專班", "高階經營管理碩士在職專班", "075", 'MC'],
          ["NTHU", "0765", "經營管理碩士在職專班", "經營管理碩士在職專班", "076", 'MC'],
          ["NTHU", "0775", "國際專業管理碩士班", "國際專業管理碩士班", "077", 'MC'],
          ["NTHU", "0785", "服務科學研究所", "服務科學研究所碩士班", "078", 'MC'],
          ["NTHU", "0788", "服務科學研究所", "服務科學研究所博士班", "078", 'DC'],
          ["NTHU", "0800", "生命科學院", "生命科學院學士班", "080", 'BC'],
          ["NTHU", "0805", "生命科學院", "生命科學院碩士班", "080", 'MC'],
          ["NTHU", "0806", "生命科學院", "生命科學院碩士班", "080", 'MC'],
          ["NTHU", "0808", "生命科學院", "生命科學院博士班", "080", 'DC'],
          ["NTHU", "0810", "生命科學系", "生命科學系學士班", "081", 'BC'],
          ["NTHU", "0820", "醫學科學系", "醫學科學系學士班", "082", 'BC'],
          ["NTHU", "0838", "跨領域神經科學博士學位學程", "跨領域神經科學博士學位學程", "083", 'DC'],

        ], :validate => false
      )

      if nthu.email_patterns.count < 1
        create(:nthu_student_email_pattern_1)
        create(:nthu_student_email_pattern_2)
        create(:nthu_staff_email_pattern)
      end
    end
  end

  factory :nthu_student_email_pattern_1, parent: :email_pattern do
    priority 10
    organization { Organization.find_by(code: 'NTHU') || create(:nthu_organization) }
    corresponded_identity UserIdentity::IDENTITES[:student]
    email_regexp '^[a-z]?(?<uid>(?<started_at>\\d{3})(?<department_code>\\d{3}(?<identity_detail>\\d))\\d{2})@(?:[a-z0-9]+\\.)?nthu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    department_code_postparser ""
    identity_detail_postparser "switch (n.toLowerCase()) { case '0': case '1': case '2': case '3': 'bachelor'; break; case '4': case '5': case '6': case '7': 'master'; break; case '8': case '9': 'doctor'; break; }"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
  end

  factory :nthu_student_email_pattern_2, parent: :email_pattern do
    priority 10
    organization { Organization.find_by(code: 'NTHU') || create(:nthu_organization) }
    corresponded_identity UserIdentity::IDENTITES[:student]
    email_regexp '^[a-z]?(?<uid>(?<started_at>\\d{2})(?<department_code>\\d{2}(?<identity_detail>\\d))\\d{2})@(?:[a-z0-9]+\\.)?nthu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    department_code_postparser "'0' + n"
    identity_detail_postparser "switch (n.toLowerCase()) { case '0': case '1': case '2': case '3': 'bachelor'; break; case '4': case '5': case '6': case '7': 'master'; break; case '8': case '9': 'doctor'; break; }"
    started_at_postparser "new Date((parseInt(n)+1911) + '-9')"
    permit_changing_department_in_group true
  end

  factory :nthu_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'NTHU') || create(:nthu_organization) }
    corresponded_identity UserIdentity::IDENTITES[:staff]
    email_regexp '^(?<uid>.+)@(?:[a-z0-9]+\\.)?nthu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    department_code_postparser ""
    identity_detail_postparser ""
    started_at_postparser ""
  end
end
