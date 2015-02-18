FactoryGirl.define do
  factory :ntu_organization, parent: :organization do
    code 'NTU'
    name '國立臺灣大學'
    short_name '台大'
    after(:create) do |ntu|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [
          ["NTU", "0020", "體育室", "體育室", nil, 'U'],
          ["NTU", "0030", "軍訓室", "軍訓室", nil, 'U'],
          ["NTU", "0040", "視聽館", "視聽館", nil, 'U'],
          ["NTU", "0050", "學務處課外活動組", "課外活動組", nil, 'U'],

          ["NTU", "1000", "文學院", "文學院", nil, 'C'],
          ["NTU", "2000", "理學院", "理學院", nil, 'C'],
          ["NTU", "3000", "社會科學院", "社科院", nil, 'C'],
          ["NTU", "4000", "醫學院", "醫學院", nil, 'C'],
          ["NTU", "5000", "工學院", "工學院", nil, 'C'],
          ["NTU", "6000", "生物資源暨農學院", "生農學院", nil, 'C'],
          ["NTU", "7000", "管理學院", "管理院", nil, 'C'],
          ["NTU", "8000", "公共衛生學院", "公衛院", nil, 'C'],
          ["NTU", "9000", "電機資訊學院", "電資院", nil, 'C'],
          ["NTU", "A000", "法律學院", "法律院", nil, 'C'],
          ["NTU", "B000", "生命科學院", "生科院", nil, 'C'],
          ["NTU", "H000", "共同教育中心", "共同教育中心", nil, 'C'],
          ["NTU", "J000", "產業研發專班", "產業研發專班", nil, 'C'],
          ["NTU", "K000", "臺灣大學聯盟", "臺灣大學聯盟", nil, 'C'],

          ["NTU", "1010", "中國文學系", "中文系", "1000", 'D'],
          ["NTU", "1011", "中國文學系國際學生學士班", "中文系國際生", "1000", 'BC'],
          ["NTU", "1020", "外國語文學系", "外文系", "1000", 'D'],
          ["NTU", "1030", "歷史學系", "歷史系", "1000", 'D'],
          ["NTU", "1040", "哲學系", "哲學系", "1000", 'D'],
          ["NTU", "1050", "人類學系", "人類系", "1000", 'D'],
          ["NTU", "1060", "圖書資訊學系", "圖資系", "1000", 'D'],
          ["NTU", "1070", "日本語文學系", "日文系", "1000", 'D'],
          ["NTU", "1080", "應用英語學系", "應用英語學系", "1000", 'D'],
          ["NTU", "1090", "戲劇學系", "戲劇系", "1000", 'D'],
          ["NTU", "1210", "中國文學研究所", "中文所", "1000", 'D'],
          ["NTU", "1220", "外國語文學研究所", "外文所", "1000", 'D'],
          ["NTU", "1230", "歷史學研究所", "歷史所", "1000", 'D'],
          ["NTU", "1240", "哲學研究所", "哲學所", "1000", 'D'],
          ["NTU", "1250", "人類學研究所", "人類所", "1000", 'D'],
          ["NTU", "1260", "圖書資訊學研究所", "圖資所", "1000", 'D'],
          ["NTU", "1270", "日本語文學研究所", "日文所", "1000", 'D'],
          ["NTU", "1290", "戲劇學研究所", "戲劇所", "1000", 'D'],
          ["NTU", "1410", "藝術史研究所", "藝史所", "1000", 'D'],
          ["NTU", "1420", "語言學研究所", "語言所", "1000", 'D'],
          ["NTU", "1440", "音樂學研究所", "音樂所", "1000", 'D'],
          ["NTU", "1450", "臺灣文學研究所", "臺文所", "1000", 'D'],
          ["NTU", "1460", "華語教學碩士學位學程", "華語教學碩士學位學程", "1000", 'P'],
          ["NTU", "1470", "翻譯碩士學位學程", "翻譯碩士學位學程", "1000", 'P'],

          ["NTU", "2010", "數學系", "數學系", "2000", 'D'],
          ["NTU", "2020", "物理學系", "物理系", "2000", 'D'],
          ["NTU", "2030", "化學系", "化學系", "2000", 'D'],
          ["NTU", "2040", "地質科學系", "地質系", "2000", 'D'],
          ["NTU", "2070", "心理學系", "心理系", "2000", 'D'],
          ["NTU", "2080", "地理環境資源學系", "地理系", "2000", 'D'],
          ["NTU", "2090", "大氣科學系", "大氣系", "2000", 'D'],
          ["NTU", "2210", "數學研究所", "數學所", "2000", 'D'],
          ["NTU", "2220", "物理學研究所", "物理所", "2000", 'D'],
          ["NTU", "2230", "化學研究所", "化學所", "2000", 'D'],
          ["NTU", "2231", "化學系化學組", "化學系化學組", "2030", 'G'],
          ["NTU", "2232", "化學系化學生物學組", "化學系化生組", "2030", 'G'],
          ["NTU", "2240", "地質科學研究所", "地質所", "2000", 'D'],
          ["NTU", "2241", "地質科學研究所地質組", "地質所地質組", "2040", 'G'],
          ["NTU", "2242", "地質科學研究所應用地質組", "地質所應用地質組", "2040", 'D'],
          ["NTU", "2250", "動物學研究所", "動物所", "2000", 'D'],
          ["NTU", "2260", "植物學研究所", "植物所", "2000", 'D'],
          ["NTU", "2270", "心理學研究所", "心理所", "2000", 'D'],
          ["NTU", "2271", "心理學研究所一般心理學組", "心理所一般心理學組", "2270", 'D'],
          ["NTU", "2272", "心理學研究所臨床心理學組", "心理所臨床心理學組", "2270", 'D'],
          ["NTU", "2280", "地理環境資源學研究所", "地理所", "2000", 'D'],
          ["NTU", "2290", "大氣科學研究所", "大氣所", "2000", 'D'],
          ["NTU", "2410", "海洋研究所", "海洋所", "2000", 'D'],
          ["NTU", "2411", "海洋研究所海洋物理組", "海洋所物理組", "2410", 'G'],
          ["NTU", "2412", "海洋研究所海洋生物及漁業組", "海洋所漁業組", "2410", 'G'],
          ["NTU", "2413", "海洋研究所海洋地質及地球物理組", "海洋所地物理", "2410", 'G'],
          ["NTU", "2414", "海洋研究所海洋化學組", "海洋所化學組", "2410", 'G'],
          ["NTU", "2420", "生化科學研究所", "生化所", "2000", 'D'],
          ["NTU", "2430", "漁業科學研究所", "漁業科學所", "2000", 'D'],
          ["NTU", "2440", "天文物理研究所", "天文物理所", "2000", 'D'],
          ["NTU", "2450", "應用物理學研究所", "應用物理所", "2000", 'D'],
          ["NTU", "2460", "應用數學科學研究所", "應數所", "2000", 'D'],

          ["NTU", "3010", "法律學系", "法律系", "3000", 'D'],
          ["NTU", "3020", "政治學系", "政治系", "3000", 'D'],
          ["NTU", "3021", "政治學系政治理論組", "政治系政論組", "3020", 'G'],
          ["NTU", "3022", "政治學系國際關係組", "政治系國關組", "3020", 'G'],
          ["NTU", "3023", "政治學系公共行政組", "政治系公行組", "3020", 'G'],
          ["NTU", "3030", "經濟學系", "經濟系", "3000", 'D'],
          ["NTU", "3050", "社會學系", "社會系", "3000", 'D'],
          ["NTU", "3051", "社會學系社會學組", "社會系社會學組", "3050", 'G'],
          ["NTU", "3052", "社會學系社會工作組", "社會系社會工作組", "3050", 'G'],
          ["NTU", "3100", "社會工作學系", "社工系", "3000", 'D'],
          ["NTU", "3220", "政治學研究所", "政治所", "3000", 'D'],
          ["NTU", "3230", "經濟學研究所", "經濟所", "3000", 'D'],
          ["NTU", "3250", "社會學研究所", "社會所", "3000", 'D'],
          ["NTU", "3300", "社會工作學研究所", "社工所", "3000", 'D'],
          ["NTU", "3410", "國家發展研究所", "國家發展所", "3000", 'D'],
          ["NTU", "3420", "新聞研究所", "新聞所", "3000", 'D'],
          ["NTU", "3430", "公共事務研究所", "公事所", "3000", 'D'],

          ["NTU", "4010", "醫學系", "醫學系", "4000", 'D'],
          ["NTU", "4020", "牙醫學系", "牙醫系", "4000", 'D'],
          ["NTU", "4030", "藥學系", "藥學系", "4000", 'D'],
          ["NTU", "4040", "醫學檢驗暨生物技術學系", "醫技系", "4000", 'D'],
          ["NTU", "4060", "護理學系", "護理系", "4000", 'D'],
          ["NTU", "4080", "物理治療學系", "物治系", "4000", 'D'],
          ["NTU", "4090", "職能治療學系", "職治系", "4000", 'D'],
          ["NTU", "4200", "醫學院暨公共衛生學院共同課程", "醫學院暨公共衛生學院共同課程", "4000", 'D'],
          ["NTU", "4210", "臨床醫學研究所", "臨床所", "4000", 'D'],
          ["NTU", "4220", "臨床牙醫學研究所", "牙醫所", "4000", 'D'],
          ["NTU", "4230", "藥學研究所", "藥學所", "4000", 'D'],
          ["NTU", "4231", "藥學系博士班藥物科技組", "藥物科技組", "4000", 'G'],
          ["NTU", "4232", "藥學系博士班分子醫藥組", "分子醫藥組", "4000", 'G'],
          ["NTU", "4240", "醫事技術學研究所", "醫技所", "4000", 'D'],
          ["NTU", "4260", "護理學研究所", "護理所", "4000", 'D'],
          ["NTU", "4280", "物理治療學研究所", "物治所", "4000", 'D'],
          ["NTU", "4290", "職能治療學研究所", "職治所", "4000", 'D'],
          ["NTU", "4410", "生理學研究所", "生理所", "4000", 'D'],
          ["NTU", "4420", "生化學研究所", "生化學所", "4000", 'D'],
          ["NTU", "4430", "藥理學研究所", "藥理所", "4000", 'D'],
          ["NTU", "4440", "病理學研究所", "病理所", "4000", 'D'],
          ["NTU", "4450", "微生物學研究所", "微生所", "4000", 'D'],
          ["NTU", "4451", "微生物學研究所微生物及免疫學組", "微生所微免組", "4450", 'G'],
          ["NTU", "4452", "微生物學研究所寄生蟲組", "微生所寄生組", "4450", 'G'],
          ["NTU", "4460", "解剖學研究所", "解剖所", "4000", 'D'],
          ["NTU", "4470", "毒理學研究所", "毒理所", "4000", 'D'],
          ["NTU", "4480", "分子醫學研究所", "分子醫學所", "4000", 'D'],
          ["NTU", "4490", "免疫學研究所", "免疫所", "4000", 'D'],
          ["NTU", "4500", "口腔生物科學研究所", "口腔生物所", "4000", 'D'],
          ["NTU", "4510", "臨床藥學研究所", "臨床藥學所", "4000", 'D'],
          ["NTU", "4520", "法醫學研究所", "法醫所", "4000", 'D'],
          ["NTU", "4530", "腫瘤醫學研究所", "腫瘤醫學所", "4000", 'D'],
          ["NTU", "4540", "腦與心智科學研究所", "腦與心智所", "4000", 'D'],
          ["NTU", "4550", "基因體暨蛋白體醫學研究所", "基蛋所", "4000", 'D'],
          ["NTU", "4560", "轉譯醫學博士學位學程", "轉譯醫學博士學位學程", "4000", 'P'],
          ["NTU", "4570", "醫學教育暨生醫倫理研究所", "醫教生倫所", "4000", 'D'],
          ["NTU", "4580", "影像醫學研究所", "影像醫學研究所", "4000", 'D'],

          ["NTU", "5010", "土木工程學系", "土木系", "5000", 'D'],
          ["NTU", "5020", "機械工程學系", "機械系", "5000", 'D'],
          ["NTU", "5040", "化學工程學系", "化工系", "5000", 'D'],
          ["NTU", "5050", "工程科學及海洋工程學系", "工科海洋系", "5000", 'D'],
          ["NTU", "5070", "材料科學與工程學系", "材料系", "5000", 'D'],
          ["NTU", "5210", "土木工程學研究所", "土木所", "5000", 'D'],
          ["NTU", "5211", "土木工程學研究所大地工程組", "土木所大地組", "5210", 'G'],
          ["NTU", "5212", "土木工程學研究所結構工程組", "土木所結構組", "5210", 'G'],
          ["NTU", "5213", "土木工程學研究所水利工程組", "土木所水利組", "5210", 'G'],
          ["NTU", "5215", "土木工程學研究所交通工程組", "土木所交通組", "5210", 'G'],
          ["NTU", "5216", "土木工程學研究所電腦輔助工程組", "土木所CAE組", "5210", 'G'],
          ["NTU", "5217", "土木工程學研究所營建工程與管理組", "土木營管組", "5210", 'G'],
          ["NTU", "5220", "機械工程學研究所", "機械所", "5000", 'D'],
          ["NTU", "5221", "機械工程學研究所流體力學組", "機械所流體力學組", "5220", 'G'],
          ["NTU", "5223", "機械工程學研究所熱學組", "機械所熱學組", "5220", 'G'],
          ["NTU", "5224", "機械工程學研究所航空工程組", "機械所航空工程組", "5220", 'G'],
          ["NTU", "5225", "機械工程學研究所固體力學組", "機械所固體力學組", "5220", 'G'],
          ["NTU", "5226", "機械工程學研究所設計組", "機械所設計組", "5220", 'G'],
          ["NTU", "5227", "機械工程學研究所製造組", "機械所製造組", "5220", 'G'],
          ["NTU", "5228", "機械工程學研究所系統控制組", "機械所系統控制組", "5220", 'G'],
          ["NTU", "5240", "化學工程學研究所", "化工所", "5000", 'D'],
          ["NTU", "5250", "工程科學及海洋工程學研究所", "工科海洋所", "5000", 'D'],
          ["NTU", "5270", "材料科學與工程學研究所", "材料所", "5000", 'D'],
          ["NTU", "5280", "水工試驗所", "水工試驗所", "5000", 'D'],
          ["NTU", "5410", "環境工程學研究所", "環工所", "5000", 'D'],
          ["NTU", "5411", "環境工程學研究所環境科學與工程組", "環工所環境科學與工程組", "5420", 'G'],
          ["NTU", "5430", "應用力學研究所", "應力所", "5000", 'D'],
          ["NTU", "5440", "建築與城鄉研究所", "建城所", "5000", 'D'],
          ["NTU", "5460", "工業工程學研究所", "工業工程所", "5000", 'D'],
          ["NTU", "5480", "醫學工程學研究所", "醫工所", "5000", 'D'],
          ["NTU", "5490", "高分子科學與工程學研究所", "高分子所", "5000", 'D'],
          ["NTU", "5510", "身心障礙者輔具工程研究中心", "身心障礙者輔具工程研究中心", "5000", 'D'],

          ["NTU", "6000", "生物資源暨農學院", "生物資源暨農學院", "6000", 'D'],
          ["NTU", "6010", "農藝學系", "農藝系", "6000", 'D'],
          ["NTU", "6020", "生物環境系統工程學系", "生工系", "6000", 'D'],
          ["NTU", "6030", "農業化學系", "農化系", "6000", 'D'],
          ["NTU", "6031", "農業化學系土壤肥料組", "農化系土壤肥料組", "6030", 'G'],
          ["NTU", "6032", "農業化學系農產製造組", "農化系農產製造組", "6030", 'G'],
          ["NTU", "6040", "植物病蟲害學系", "植物病蟲害學系", "6000", 'D'],
          ["NTU", "6050", "森林環境暨資源學系", "森林環資系", "6000", 'D'],
          ["NTU", "6051", "森林環境暨資源學系育林組", "森林環資系育林組", "6050", 'G'],
          ["NTU", "6052", "森林環境暨資源學系資源管理組", "森林環資系資源管理組", "6050", 'G'],
          ["NTU", "6053", "森林環境暨資源學系森林工業組", "森林環資系森林工業組", "6050", 'G'],
          ["NTU", "6054", "森林環境暨資源學系森林資源保育組", "森林環資系森林資源保育組", "6050", 'G'],
          ["NTU", "6060", "動物科學技術學系", "動科系", "6000", 'D'],
          ["NTU", "6070", "農業經濟學系", "農經系", "6000", 'D'],
          ["NTU", "6080", "園藝暨景觀學系", "園藝暨景觀學系", "6000", 'D'],
          ["NTU", "6090", "獸醫學系", "獸醫系", "6000", 'D'],
          ["NTU", "6100", "生物產業傳播暨發展學系", "生傳發展系", "6000", 'D'],
          ["NTU", "6101", "生物產業傳播暨發展學系推廣教育組", "生傳發展系推廣教育組", "6100", 'G'],
          ["NTU", "6102", "生物產業傳播暨發展學系鄉村社會組", "生傳發展系鄉村社會組", "6100", 'G'],
          ["NTU", "6110", "生物產業機電工程學系", "生機系", "6000", 'D'],
          ["NTU", "6120", "昆蟲學系", "昆蟲系", "6000", 'D'],
          ["NTU", "6130", "植物病理與微生物學系", "植微系", "6000", 'D'],
          ["NTU", "6210", "農藝學研究所", "農藝所", "6000", 'D'],
          ["NTU", "6211", "農藝學研究所作物科學組", "農藝所作物組", "6211", 'G'],
          ["NTU", "6212", "農藝學研究所生物統計學組", "農藝所生統組", "6211", 'G'],
          ["NTU", "6220", "生物環境系統工程學研究所", "生工所", "6000", 'D'],
          ["NTU", "6230", "農業化學研究所", "農化所", "6000", 'D'],
          ["NTU", "6234", "農業化學研究所土壤環境與植物營養組", "農化所土壤環境與植物營養組", "6230", 'D'],
          ["NTU", "6235", "農業化學研究所生物工業化學組", "農化所生物工業化學組", "6230", 'D'],
          ["NTU", "6236", "農業化學研究所生物化學組", "農化所生物化學組", "6230", 'G'],
          ["NTU", "6237", "農業化學研究所營養科學組", "農化所營養科學組", "6230", 'G'],
          ["NTU", "6238", "農業化學研究所微生物學組", "農化所微生物學組", "6230", 'G'],
          ["NTU", "6250", "森林學研究所", "森林所", "6000", 'D'],
          ["NTU", "6260", "動物科學技術研究所", "動科所", "6000", 'D'],
          ["NTU", "6270", "農業經濟學研究所", "農經所", "6000", 'D'],
          ["NTU", "6280", "園藝暨景觀學研究所", "園藝所", "6000", 'D'],
          ["NTU", "6281", "園藝暨景觀學研究所園藝作物組", "園藝所作物組", "6280", 'G'],
          ["NTU", "6282", "園藝暨景觀學研究所園產品處理及利用組", "園藝所園產組", "6280", 'G'],
          ["NTU", "6283", "園藝暨景觀學研究所景觀暨休憩組", "園藝所景觀組", "6280", 'G'],
          ["NTU", "6290", "獸醫學研究所", "獸醫所", "6000", 'D'],
          ["NTU", "6300", "生物產業傳播暨發展研究所", "生傳發展所", "6000", 'D'],
          ["NTU", "6310", "生物產業機電工程學所", "生機所", "6000", 'D'],
          ["NTU", "6320", "昆蟲學研究所", "昆蟲所", "6000", 'D'],
          ["NTU", "6330", "植物病理與微生物學研究所", "植病所", "6000", 'D'],
          ["NTU", "6410", "食品科技研究所", "食科所", "6000", 'D'],
          ["NTU", "6420", "生物科技研究所", "生物科技所", "6000", 'D'],
          ["NTU", "6430", "臨床動物醫學研究所", "臨床動醫所", "6000", 'D'],
          ["NTU", "6440", "分子暨比較病理生物學研究所", "分子比病所", "6000", 'D'],
          ["NTU", "6450", "植物醫學碩士學位學程", "植物醫學碩士學位學程", "6000", 'P'],

          ["NTU", "7010", "工商管理學系", "工管系", "7000", 'D'],
          ["NTU", "7011", "工商管理學系企業管理組", "工管系企管組", "7010", 'G'],
          ["NTU", "7012", "工商管理學系科技管理組", "工管系科管組", "7010", 'G'],
          ["NTU", "7013", "工商管理系企業管理組英文專班", "工商管理系企業管理組英文專班", "7000", 'D'],
          ["NTU", "7020", "會計學系", "會計系", "7f000", 'D'],
          ["NTU", "7030", "財務金融學系", "財金系", "7000", 'D'],
          ["NTU", "7040", "國際企業學系", "國企系", "7000", 'D'],
          ["NTU", "7050", "資訊管理學系", "資管系", "7000", 'D'],
          ["NTU", "7060", "企業管理學系", "企管系", "7000", 'D'],
          ["NTU", "7220", "會計學研究所", "會計所", "7000", 'D'],
          ["NTU", "7230", "財務金融學研究所", "財金所", "7000", 'D'],
          ["NTU", "7240", "國際企業學研究所", "國際企業所", "7000", 'D'],
          ["NTU", "7250", "資訊管理學研究所", "資訊管理所", "7000", 'D'],
          ["NTU", "7400", "高階管理碩士專班", "高階管理碩士專班", "7000", 'D'],
          ["NTU", "7410", "商學研究所", "商研所", "7000", 'D'],
          ["NTU", "7420", "商學研究所知識管理組", "商研所知識管理組", "7410", 'G'],
          ["NTU", "7430", "管理學院高階公共管理組", "管理學院高階公共管理組", "7000", 'G'],
          ["NTU", "7440", "管理學院會計與管理決策組", "管理學院會計與管理決策組", "7000", 'G'],
          ["NTU", "7450", "管理學院財務金融組", "管理學院財務金融組", "7000", 'G'],
          ["NTU", "7460", "管理學院國際企業管理組", "管理學院國際企業管理組", "7000", 'G'],
          ["NTU", "7470", "管理學院資訊管理組", "管理學院資訊管理組", "7000", 'G'],
          ["NTU", "7480", "管理學院商學組", "管理學院商學組", "7000", 'G'],
          ["NTU", "7490", "管理學院企業管理碩士專班", "管理學院企業管理碩士專班", "7000", 'D'],
          ["NTU", "7500", "臺大-復旦EMBA", "臺大-復旦EMBA", "7000", 'D'],

          ["NTU", "8010", "公共衛生學系", "公衛系", "8000", 'D'],
          ["NTU", "8410", "職業醫學與工業衛生研究所", "職醫工衛所", "8000", 'D'],
          ["NTU", "8420", "流行病學研究所", "流行病學研究所", "8000", 'D'],
          ["NTU", "8430", "醫療機構管理研究所", "醫療機構管理研究所", "8000", 'D'],
          ["NTU", "8440", "環境衛生研究所", "環衛所", "8000", 'D'],
          ["NTU", "8450", "衛生政策與管理研究所", "衛生政策與管理研究所", "8000", 'D'],
          ["NTU", "8460", "預防醫學研究所", "預防醫學研究所", "8000", 'D'],
          ["NTU", "8470", "公共衛生碩士學位學程", "公共衛生碩士學程", "8000", 'P'],
          ["NTU", "8480", "健康政策與管理研究所", "健管所", "8000", 'D'],
          ["NTU", "8481", "健管所健促組", "健康促進組", "8480", 'G'],
          ["NTU", "8482", "健管所健產組", "健康與產業組", "8480", 'G'],
          ["NTU", "8490", "流行病學與預防醫學研究所", "流預所", "8000", 'D'],
          ["NTU", "8491", "流預所流行病學組", "流預所流病組", "8490", 'G'],
          ["NTU", "8492", "流預所生物醫學統計組", "流預所生統組", "8490", 'G'],
          ["NTU", "8493", "流預所預防醫學組", "流預所預醫組", "8490", 'G'],

          ["NTU", "9010", "電機工程學系", "電機系", "9000", 'D'],
          ["NTU", "9020", "資訊工程學系", "資工系", "9000", 'D'],
          ["NTU", "9210", "電機工程學研究所", "電機所", "9000", 'D'],
          ["NTU", "9220", "資訊工程學研究所", "資工所", "9000", 'D'],
          ["NTU", "9410", "光電工程學研究所", "光電所", "9000", 'D'],
          ["NTU", "9420", "電信工程學研究所", "電信所", "9000", 'D'],
          ["NTU", "9430", "電子工程學研究所", "電子所", "9000", 'D'],
          ["NTU", "9440", "資訊網路與多媒體研究所", "網媒所", "9000", 'D'],
          ["NTU", "9450", "生醫電子與資訊學研究所", "生醫電資所", "9000", 'D'],

          ["NTU", "A010", "法律學系", "法律系", "A000", 'D'],
          ["NTU", "A011", "法律系法學組", "法律系法學組", "A010", 'G'],
          ["NTU", "A012", "法律系司法組", "法律系司法組", "A010", 'G'],
          ["NTU", "A013", "法律系財法組", "法律系財法組", "A010", 'G'],
          ["NTU", "A210", "法律研究所", "法律所", "A000", 'D'],
          ["NTU", "A410", "科際整合法律學研究所", "科法所", "A000", 'D'],

          ["NTU", "B010", "生命科學系", "生命科學系", "B000", 'D'],
          ["NTU", "B020", "生化科技學系", "生化科技學系", "B000", 'D'],
          ["NTU", "B210", "生命科學所", "生科所", "B000", 'D'],
          ["NTU", "B220", "生化科技研究所", "生化科技所", "B000", 'D'],
          ["NTU", "B410", "動物學研究所", "動物學研究所", "B000", 'D'],
          ["NTU", "B420", "植物科學研究所", "植物科學所", "B000", 'D'],
          ["NTU", "B430", "分子與細胞生物學研究所", "分子細生所", "B000", 'D'],
          ["NTU", "B440", "生態學與演化生物學研究所", "生態演化所", "B000", 'D'],
          ["NTU", "B450", "漁業科學研究所", "漁業科學所", "B000", 'D'],
          ["NTU", "B460", "生化科學研究所", "生化科學所", "B000", 'D'],
          ["NTU", "B470", "微生物與生化學研究所", "微生物生化所", "B000", 'D'],
          ["NTU", "B471", "微生物與生化學研究所生物工業組", "微生物生化所生物工業組", "B470", 'G'],
          ["NTU", "B472", "微生物與生化學研究所生物化學組", "微生物生化所生物化學組", "B470", 'G'],
          ["NTU", "B473", "微生物與生化學研究所營養科學組", "微生物生化所營養科學組", "B470", 'G'],
          ["NTU", "B474", "微生物與生化學研究所微生物學組", "微生物生化所微生物學組", "B470", 'G'],
          ["NTU", "B480", "基因體與系統生物學學位學程", "基因體與系統生物學學位學程", "B000", 'P'],

          ["NTU", "H010", "共同教育中心", "共教中心", "H000", 'D'],
          ["NTU", "H020", "共同教育中心", "共教中心", "H000", 'D'],
          ["NTU", "H410", "統計碩士學位學程", "統計碩士學位學程", "H000", 'P'],

          ["NTU", "J100", "電機產業專班", "電機產業專班", "J000", 'D'],
          ["NTU", "J110", "資訊產業專班", "資訊產業專班", "J000", 'D' ]

        ], :validate => false
      )

    end
  end

  factory :ntu_student_email_pattern, parent: :email_pattern do
    priority 10
    organization { Organization.find_by(code: 'NTU') || create(:ntu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^(?<uid>(?<identity_detail>[aAbmdBMD])(?<started_at>\\d{2})(?<department_code>\\d{4})\\d{1,4})@ntu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    department_code_postparser "n"
    identity_detail_postparser "switch (n.toLowerCase()) { case 'a': 'a'; break; case 'b': 'bachelor'; break; case 'm': 'master'; break; case 'd': 'doctor'; break; }"
    started_at_postparser "new Date((parseInt(n)+1911+100) + '-9')"
    permit_changing_department_in_group true
  end

  factory :ntu_staff_email_pattern, parent: :email_pattern do
    priority 20
    organization { Organization.find_by(code: 'NTU') || create(:ntu_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@ntu\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
  end
end
