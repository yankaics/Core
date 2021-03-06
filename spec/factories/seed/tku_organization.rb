FactoryGirl.define do
  factory :tku_organization, parent: :organization do
    code 'TKU'
    name '淡江大學'
    short_name '淡江'
    after(:create) do |tku|
      columns = [:organization_code, :code, :name, :short_name, :parent_code, :group]
      Department.import(columns,
        [
          ["TKU", "TA", "文學院", "文學院", nil, 'C'],
          ["TKU", "TS", "理學院", "理學院", nil, 'C'],
          ["TKU", "TE", "工學院", "工學院", nil, 'C'],
          ["TKU", "TL", "商管學院", "商管學院", nil, 'C'],
          ["TKU", "TF", "外國語文學院", "外國語文學院", nil, 'C'],
          ["TKU", "TI", "國際研究學院", "國際研究學院", nil, 'C'],
          ["TKU", "TD", "教育學院", "教育學院", nil, 'C'],
          ["TKU", "TQ", "全球發展學院", "全球發展學院", nil, 'C'],

          ["TKU", "TACX",  "中國文學學系", "中文系", "TA", 'D'],
          ["TKU", "TACXB", "中國文學學系學士班", "中文系（日）", "TACX", 'BC'],
          ["TKU", "TACXE", "中國文學學系進修學士班", "中文系（進學）", "TACX", 'EC'],
          ["TKU", "TACXM", "中國文學學系碩士班", "中文系碩士班", "TACX", 'D'],
          ["TKU", "TACAM", "中國文學學系碩士班文學組", "中研所文學組", "TACXM", 'G'],
          ["TKU", "TACBM", "中國文學學系碩士班語言文化組", "中研所語言文化組", "TACXM", 'G'],
          ["TKU", "TACXJ", "中國文學學系碩士在職專班", "中文系碩專班", "TACXM", 'D'],
          ["TKU", "TACXD", "中國文學學系博士班", "中文系博士班", "TACX", 'D'],
          ["TKU", "TADXM", "漢語文化暨文獻資源研究所碩士班", "語獻所碩士班", "TA", 'MC'],

          ["TKU", "TAHX",  "歷史學系", "歷史系", "TA", 'D'],
          ["TKU", "TAHXB", "歷史學系學士班", "歷史系（日）", "TAHX", 'BC'],
          ["TKU", "TAHXM", "歷史學系碩士班", "歷史系碩士班", "TAHX", 'D'],
          ["TKU", "TAHXJ", "歷史學系碩士在職專班", "歷史系碩專班", "TAHX", 'D'],

          ["TKU", "TABX",  "資訊與圖書館學系", "資圖系（日）", "TA", 'D'],
          ["TKU", "TABXB", "資訊與圖書館學系學士班", "資圖系", "TABX", 'BC'],
          ["TKU", "TABXM", "資訊與圖書館學系碩士班", "資圖系碩士班", "TABX", 'MC'],
          ["TKU", "TABAJ", "資訊與圖書館學系數位碩專班", "資圖系數位碩專班", "TABX", 'JC'],

          ["TKU", "TAMX",  "大眾傳播學系", "大傳系", "TA", 'D'],
          ["TKU", "TAMXB", "大眾傳播學系學士班", "大傳系（日）", "TAMX", 'BC'],
          ["TKU", "TAMXM", "大眾傳播學系碩士班", "大傳系傳播碩士班", "TAMX", 'MC'],

          ["TKU", "TAIX",  "資訊傳播學系", "資傳系", "TA", 'D'],
          ["TKU", "TAIXB", "資訊傳播學系學士班", "資傳系（日）", "TAIX", 'BC'],
          ["TKU", "TAIXM", "資訊傳播學系碩士班", "資訊傳播學系", "TAIX", 'MC'],

          # ["TKU", "005", "漢學研究中心", "漢學研究中心", "TA", 'D'],

          ["TKU", "TSMX", "數學學系", "數學系", "TS", 'D'],
          ["TKU", "TSMXB", "數學學系學士班", "數學系（日）", "TSMX", 'BC'],
          ["TKU", "TSMAB", "數學學系學士班數學組", "數學系數學組－日", "TSMXB", 'G'],
          ["TKU", "TSMCB", "數學學系學士班資統組", "數學系資統組－日", "TSMXB", 'G'],
          ["TKU", "TSMXM", "數學學系碩士班", "數學系碩士班", "TSMX", 'MC'],
          ["TKU", "TSMXJ", "數學教學碩士班", "數學教學碩士班", "TSMX", 'MC'],
          ["TKU", "TSMXD", "數學學系博士班", "數學系博士班", "TSMX", 'DC'],

          ["TKU", "TSPX", "物理學系", "物理系", "TS", 'D'],
          ["TKU", "TSPXB", "物理學系學士班", "物理系（日）", "TSPX", 'BC'],
          ["TKU", "TSPBB", "物理學系學士班應物組", "物理系應物組－日", "TSPXB", 'G'],
          ["TKU", "TSPCB", "物理學系學士班光電組", "物理系光電組－日", "TSPXB", 'G'],
          ["TKU", "TSPXM", "物理學系碩士班", "物理系碩士班", "TSPX", 'MC'],
          ["TKU", "TSPXD", "物理學系博士班", "物理系博士班", "TSPX", 'DC'],

          ["TKU", "TSCX",  "化學學系", "化學系", "TS", 'D'],
          ["TKU", "TSCXB", "化學學系學士班", "化學系（日）", "TSCX", 'BC'],
          ["TKU", "TSCCB", "化學學系學士班生化組", "化學系生化組－日", "TSCXB", 'G'],
          ["TKU", "TSCDB", "化學學系學士班材化組", "化學系材化組－日", "TSCXB", 'G'],
          ["TKU", "TSCXM", "化學所", "化學所", "TSCX", 'D'],
          ["TKU", "TSCAM", "化學所化學組", "化學所化學組", "TSCXM", 'G'],
          ["TKU", "TSCCM", "化學所生物組", "化學所生物組", "TSCXM", 'G'],
          ["TKU", "TSCXD", "化學所博士班", "化學系博士班", "TSCXM", 'DC'],
          ["TKU", "TSLXM", "生命科學所碩士班", "生科所碩士班", "TSCXM", 'MC'],

          ["TKU", "TSBXB", "理學院學士班", "理學院學士班", "TS", 'D'],

          ["TKU", "TEAX",  "建築學系", "建築系", "TE", 'D'],
          ["TKU", "TEAXB", "建築學系學士班", "建築系（日）", "TEAX", 'BC'],
          ["TKU", "TEAXM", "建築學系碩士班", "建築系碩士班", "TEAX", 'MC'],

          ["TKU", "TECX",  "土木工程學系", "土木系", "TE", 'D'],
          ["TKU", "TECXB", "土木工程學系學士班", "土木系", "TECX", 'BC'],
          ["TKU", "TECAB", "土木工程學系學士班工設組", "土木系工設組－日", "TECXB", 'G'],
          ["TKU", "TECBB", "土木工程學系學士班營企阻", "土木系營企組－日", "TECXB", 'G'],
          ["TKU", "TECXM", "土木工程學系碩士班", "土木系碩士班", "TECX", 'MC'],
          ["TKU", "TECXD", "土木工程學系博士班", "土木系博士班", "TECX", 'DC'],

          ["TKU", "TEWX",  "水資源及環境工程學系", "水環系", "TE", 'D'],
          ["TKU", "TEWXB", "水資源及環境工程學系學士班", "水環系（日）", "TEWX", 'BC'],
          ["TKU", "TEWAB", "水資源及環境工程學系水資源組", "水環系水資源組", "TEWXB", 'G'],
          ["TKU", "TEWBB", "水資源及環境工程學系環工組", "水環系環工組", "TEWXB", 'G'],
          ["TKU", "TEWXM", "水資源及環境工程學系", "水環系碩士班", "TEWX", 'MC'],
          ["TKU", "TEWXD", "水資源及環境工程學系", "水環系博士班", "TEWX", 'DC'],

          ["TKU", "TEBX",  "機械與機電工程學系", "機電系", "TE", 'D'],
          ["TKU", "TEBXB", "機械與機電工程學系學士班", "機電系（日）", "TEBX", 'BC'],
          ["TKU", "TEBAB", "機械與機電工程學系光機電整合", "機電系光機電整合", "TEBXB", 'G'],
          ["TKU", "TEBBB", "機械與機電工程學系精密機械組", "機電系精密機械組", "TEBXB", 'G'],
          ["TKU", "TEBXM", "機械與機電工程學系碩士班", "機電系碩士班", "TEBX", 'MC'],
          ["TKU", "TEBAM", "機械與機電工程學系碩士班光機電", "機電系碩班光機電", "TEBXM", 'G'],
          ["TKU", "TEBBM", "機械與機電工程學系碩士班精機", "機電系碩班精機", "TEBXM", 'G'],
          ["TKU", "TEBXD", "機械與機電工程學系博士班", "機電系博士班", "TE", 'D'],

          ["TKU", "TEDX",  "化學工程與材料工程學系", "化材系", "TE", 'D'],
          ["TKU", "TEDXB", "化學工程與材料工程學系學士班", "化材系（日）", "TEDX", 'BC'],
          ["TKU", "TEDXM", "化學工程與材料工程學系碩士班", "化材系碩士班", "TEDX", 'MC'],
          ["TKU", "TEDXD", "化學工程與材料工程學系博士班", "化材系博士班", "TEDX", 'DC'],

          ["TKU", "TETX",  "電機工程學系", "電機系", "TE", 'D'],
          ["TKU", "TETXB", "電機工程學系學士班", "電機系（日）", "TETX", 'BC'],
          ["TKU", "TETAB", "電機工程學系電資", "電機系電資（日）", "TETXB", 'G'],
          ["TKU", "TETBB", "電機工程學系電通", "電機系電通（日）", "TETXB", 'G'],
          ["TKU", "TETCB", "電機工程學系電機", "電機系電機（日）", "TETXB", 'G'],
          ["TKU", "TETXE", "電機工程學系進修學士班", "電機系（進學）", "TETX", 'EC'],
          ["TKU", "TETXM", "電機工程學系碩士班", "電機系碩士班", "TETX", 'MC'],
          ["TKU", "TETBM", "電機工程學系碩士班電路組", "電機系碩士班電路", "TETXM", 'G'],
          ["TKU", "TETDM", "電機工程學系碩士班控制組", "電機系碩士班控制", "TETXM", 'G'],
          ["TKU", "TETEM", "電機工程學系碩士班碩士組", "電機系機器人碩士", "TETXM", 'G'],
          ["TKU", "TETGM", "電機工程學系碩士班通訊組", "電機系碩士班通訊", "TETXM", 'G'],
          ["TKU", "TETXJ", "電機工程學系碩士在職專班", "電機系碩專班", "TETXM", 'JC'],
          ["TKU", "TETXD", "電機工程學系博士班", "電機系博士班", "TETX", 'DC'],

          ["TKU", "TEIX",  "資訊工程學系", "資工系", "TE", 'D'],
          ["TKU", "TEIXB", "資訊工程學系學士班", "資工系（日）", "TEIX", 'BC'],
          ["TKU", "TEIXE", "資訊工程學系進修學士班", "資工系（進學）", "TEIX", 'EC'],
          ["TKU", "TEIXM", "資訊工程學系碩士班", "資工系碩士班", "TEIX", 'MC'],
          ["TKU", "TEIAM", "資訊工程學系資網所", "資工系資網所", "TEIXM", 'G'],
          ["TKU", "TEIBM", "資訊工程學系英語碩士班", "資工系英語碩士班", "TEIXM", 'G'],
          ["TKU", "TEIXJ", "資訊工程學系碩士在職專班", "資工系碩專班", "TEIXM", 'JC'],
          ["TKU", "TEIXD", "資訊工程學系博士班", "資工系博士班", "TEIX", 'DC'],

          ["TKU", "TENX",  "航空太空工程學系", "航太系", "TE", 'D'],
          ["TKU", "TENXB", "航空太空工程學系學士班", "航太系（日）", "TE", 'BC'],
          ["TKU", "TENXM", "航空太空工程學系碩士班", "航太系碩士班", "TE", 'MC'],

          ["TKU", "TLFX",  "國際企業學系", "國企系", "TL", 'D'],
          ["TKU", "TLFXB", "國際企業學系學士班", "國企系（日）", "TLFX", 'BC'],
          ["TKU", "TLFXE", "國際企業學系進修學士班", "國企系（進學）", "TLFX", 'EC'],
          ["TKU", "TLFXM", "國際企業學系碩士班", "國企系碩士班", "TLFX", 'MC'],
          ["TKU", "TLFXJ", "國際企業學系碩士在職專班", "國企系碩專班", "TLFX", 'JC'],
          ["TKU", "TLFAJ", "國企所暨國行所碩士在職專班", "國企系國行碩專班", "TLFX", 'JC'],

          ["TKU", "TLBX",  "財務金融學系", "財金系", "TL", 'D'],
          ["TKU", "TLBXB", "財務金融學系學士班", "財金系（日）", "TLBX", 'BC'],
          ["TKU", "TLBXE", "財務金融學系進修學士班", "財金系（進學）", "TLBX", 'EC'],
          ["TKU", "TLBXM", "財務金融學系碩士班", "財金系碩士班", "TLBX", 'MC'],
          ["TKU", "TLBXJ", "財務金融學系碩士在職專班", "財金系碩專班", "TLBX", 'JC'],
          ["TKU", "TLBXD", "財務金融學系博士班", "財金系博士班", "TLBX", 'DC'],

          ["TKU", "TLIX",  "保險學系", "保險系", "TL", 'D'],
          ["TKU", "TLIXB", "保險學系學士班", "保險系（日）", "TLIX", 'BC'],
          ["TKU", "TLIXM", "保險學系碩士班", "保險系碩士班", "TLIX", 'MC'],
          ["TKU", "TLIXJ", "保險學系碩士在職專班", "保險系碩專班", "TLIX", 'JC'],

          ["TKU", "TLLXJ", "全球華商經營管理數位學習碩士在職專班", "華商經管數位碩專", "TL", 'JC'],

          ["TKU", "TLEX",  "產業經濟學系", "產業經濟學系", "TL", 'D'],
          ["TKU", "TLEXB", "產業經濟學系學士班", "產經系（日）", "TLEX", 'BC'],
          ["TKU", "TLEXM", "產業經濟學系碩士班", "產經系碩士班", "TLEX", 'MC'],
          ["TKU", "TLEXD", "產業經濟學系博士班", "產經系博士班", "TLEX", 'DC'],

          ["TKU", "TLYX",  "經濟學系", "經濟系", "TL", 'D'],
          ["TKU", "TLYXB", "經濟學系學士班", "經濟系（日）", "TLYX", 'BC'],
          ["TKU", "TLYXM", "經濟學系碩士班", "經濟系碩士班", "TLYX", 'MC'],

          ["TKU", "TLCX",  "企業管理學系", "企管系", "TL", 'D'],
          ["TKU", "TLCXB", "企業管理學系學士班", "企管系（日）", "TLCX", 'BC'],
          ["TKU", "TLCXE", "企業管理學系進修學士班", "企管系（進學）", "TLCX", 'EC'],
          ["TKU", "TLCXJ", "企業管理學系碩士在職專班", "企管系碩專班", "TLCX", 'JC'],
          ["TKU", "TLCXE", "企業管理學系碩士班", "企管系碩士班", "TLCX", 'MC'],

          ["TKU", "TLAX",  "會計學系", "會計系", "TL", 'D'],
          ["TKU", "TLAXB", "會計學系學士班", "會計系（日）", "TLAX", 'BC'],
          ["TKU", "TLAXE", "會計學系進修學士班", "會計系（進學）", "TLAX", 'EC'],
          ["TKU", "TLAXM", "會計學系碩士班", "會計系碩士班", "TLAX", 'MC'],
          ["TKU", "TLAXJ", "會計學系碩士在職專班", "會計系碩專班", "TLAX", 'JC'],

          ["TKU", "TLSX",  "統計學系", "統計系", "TL", 'D'],
          ["TKU", "TLSXB", "統計學系學士班", "統計系（日）", "TLSX", 'BC'],
          ["TKU", "TLSXE", "統計學系進修學士班", "統計系（進學）", "TLSX", 'EC'],
          ["TKU", "TLSXM", "統計學系碩士班", "統計系應統碩士班", "TLSX", 'MC'],

          ["TKU", "TLMX",  "資訊管理學系", "資管系", "TL", 'D'],
          ["TKU", "TLMXB", "資訊管理學系學士班", "資管系（日）", "TLMX", 'BC'],
          ["TKU", "TLMXM", "資訊管理學系碩士班", "資管系碩士班", "TLMX", 'MC'],
          ["TKU", "TLMXJ", "資訊管理學系碩士在職專班", "資管系碩專班", "TLMX", 'JC'],

          ["TKU", "TLTX",  "運輸管理學系", "運管系", "TL", 'D'],
          ["TKU", "TLTXB", "運輸管理學系學士班", "運管系（日）", "TLTX", 'BC'],
          ["TKU", "TLTXM", "運輸管理學系運科碩士班", "運管系運科碩士班", "TLTX", 'MC'],

          ["TKU", "TLPX",  "公共行政學系", "公行系", "TL", 'D'],
          ["TKU", "TLPXB", "公共行政學系學士班", "公行系（日）", "TLPX", 'BC'],
          ["TKU", "TLPXE", "公共行政學系進修學士班", "公行系（進學）", "TLPX", 'EC'],
          ["TKU", "TLPXM", "公共行政學系碩士班", "公行系政策碩士班", "TLPX", 'MC'],
          ["TKU", "TLPXJ", "公共行政學系碩士在職專班", "公行系碩專班", "TLPX", 'JC'],

          ["TKU", "TLGX",  "管理科學學系", "管科系", "TL", 'D'],
          ["TKU", "TLGXB", "管理科學學系學士班", "管科系（日）", "TLGX", 'BC'],
          ["TKU", "TLGXM", "管理科學學系碩士班", "管科系碩士班", "TLGX", 'MC'],
          ["TKU", "TLGXJ", "管理科學學系企業經營碩士在職專班", "管科系企經碩專班", "TLGX", 'JC'],
          ["TKU", "TLGXD", "管理科學學系博士班", "管科系博士班", "TLGX", 'DC'],

          ["TKU", "0312", "商管碩士在職專班", "商管碩士在職專班", "TL", 'D'],
          ["TKU", "0313", "商管AACSB認證辦公室", "商管AACSB認證辦公室", "TL", 'D'],

          ["TKU", "TFLX",  "英文學系", "英文系", "TF", 'D'],
          ["TKU", "TFLXB", "英文學系學士班", "英文系（日）", "TFLX", 'BC'],
          ["TKU", "TFLXE", "英文學系進修學士班", "英文系（進學）", "TFLX", 'EC'],
          ["TKU", "TFLXM", "英文學系碩士班", "英文學系碩士班", "TFLX", 'MC'],
          ["TKU", "TFLXD", "英文學系博士班", "英文系博士班", "TFLX", 'DC'],

          ["TKU", "TFSX",  "西班牙語文學系", "西班牙語文學系", "TF", 'D'],
          ["TKU", "TFSXB", "西班牙語文學系學士班", "西語系（日）", "TFSX", 'BC'],
          ["TKU", "TFSXM", "西班牙語文學系碩士班", "西語系碩士班", "TFSX", 'MC'],

          ["TKU", "TFFX",  "法國語文學系", "法文系", "TF", 'D'],
          ["TKU", "TFFXB", "法國語文學系學士班", "法文系（日）", "TFFX", 'BC'],
          ["TKU", "TFFXM", "法國語文學系碩士班", "法文系碩士班", "TFFX", 'MC'],

          ["TKU", "TFGX",  "德國語文學系", "德國語文學系", "TF", 'D'],
          ["TKU", "TFGXB", "德國語文學系", "德文系（日）", "TFGX", 'BC'],

          ["TKU", "TFJX",  "日本語文學系", "日文系", "TF", 'D'],
          ["TKU", "TFJXB", "日本語文學系學士班", "日文系（日）", "TFJX", 'BC'],
          ["TKU", "TFJXE", "日本語文學系進修學士班", "日文系（進學）", "TFJX", 'EC'],
          ["TKU", "TFJXK", "日本語文學系在職專班", "日文系在職專班", "TFJX", 'JC'],
          ["TKU", "TFJXM", "日本語文學系碩士班", "日文系碩士班", "TFJX", 'MC'],
          ["TKU", "TFJXJ", "日本語文學系碩士在職專班", "日文系碩專班", "TFJXM", 'JC'],

          ["TKU", "TFUX",  "俄國語文學系", "俄文系", "TF", 'D'],
          ["TKU", "TFUXB", "俄國語文學系學士班", "俄文系（日）", "TFUX", 'BC'],

          ["TKU", "TIEX",  "歐洲研究所", "歐洲研究所", "TI", 'D'],
          ["TKU", "TIEXM", "歐洲研究所碩士班", "歐研所碩士班", "TIEX", 'MC'],
          ["TKU", "TIEAM", "歐洲研究所碩士班歐盟組", "歐研所歐盟組", "TIEXDM", 'G'],
          ["TKU", "TIEBM", "歐洲研究所碩士班俄研組", "歐研所俄研組", "TIEXDM", 'G'],
          ["TKU", "TIEXD", "歐洲研究所博士班", "歐洲所博士班", "TI", 'DC'],

          ["TKU", "TIFX",  "美洲研究所", "美洲所", "TI", 'D'],
          ["TKU", "TIFXM", "美洲研究所碩士班", "美洲所碩士班", "TIFX", 'MC'],
          ["TKU", "TIFAM", "美洲研究所碩士班美研組", "美洲所美研組", "TIFXM", 'G'],
          ["TKU", "TIFBM", "美洲研究所碩士班拉研組", "美洲所拉研組", "TIFXM", 'G'],
          ["TKU", "TIFXD", "美洲研究所博士班", "美洲所博士班", "TIFX", 'DC'],

          ["TKU", "TILX",  "拉丁美洲研究所", "拉研所", "TI", 'D'],
          ["TKU", "TILXM", "拉丁美洲研究所碩士班", "拉研所碩士班", "TILX", 'MC'],

          ["TKU", "TIBX",  "東南亞研究所", "東南亞所", "TI", 'D'],
          ["TKU", "TIBXM", "東南亞研究所碩士班", "東南亞所碩士班", "TIBX", 'MC'],

          ["TKU", "TITX",  "國際事務與戰略研究所", "戰略所", "TI", 'D'],
          ["TKU", "TITXM", "國際事務與戰略研究所碩士班", "戰略所碩士班", "TITX", 'MC'],
          ["TKU", "TITXJ", "國際事務與戰略研究所碩士在職專班", "戰略所碩專班", "TITX", 'JC'],
          ["TKU", "TITXD", "國際事務與戰略研究所博士班", "戰略所博士班", "TITX", 'DC'],

          ["TKU", "TIIX",  "亞洲研究所", "亞洲所", "TI", 'D'],
          ["TKU", "TIIXM", "亞洲研究所碩士班", "亞洲所碩士班", "TIIX", 'MC'],
          ["TKU", "TIIAM", "亞洲研究所碩士班日本組", "亞洲所日本組", "TIIXM", 'G'],
          ["TKU", "TIIBM", "亞洲研究所碩士班東南亞組", "亞洲所東南亞組", "TIIXM", 'G'],
          ["TKU", "TIICM", "亞洲研究所碩士班數位碩專班", "亞洲所數位碩專班", "TIIXM", 'G'],
          ["TKU", "TIIXJ", "亞洲研究所碩士在職專班", "亞洲所碩專班", "TIIX", 'JC'],

          ["TKU", "TICX",  "中國大陸研究所", "大陸所", "TI", 'D'],
          ["TKU", "TICXM", "中國大陸研究所碩士班", "大陸所碩士班", "TICX", 'MC'],
          ["TKU", "TICAM", "中國大陸研究所碩士班文教", "大陸所碩士班文教", "TICXM", 'G'],
          ["TKU", "TICBM", "中國大陸研究所碩士班經貿", "大陸所碩士班經貿", "TICXM", 'G'],
          ["TKU", "TICXJ", "中國大陸研究所碩士在職專班", "大陸所碩專班", "TI", 'D'],

          ["TKU", "TIPXM", "臺灣與亞太研究全英語碩士學位學程", "臺灣與亞太研究全英語碩士學位學程", "TI", 'P'],

          ["TKU", "TISX",  "俄國研究所", "俄研所", "TI", 'D'],
          ["TKU", "TISXM", "俄國研究所碩士班", "俄研所碩士班", "TISX", 'MC'],

          # ["TKU", "056", "外交與國際關係學系全英語學士班", "外交與國際關係學系全英語學士班", "TI", 'D'],

          ["TKU", "TDTX",  "教育科技學系", "教科系", "TD", 'D'],
          ["TKU", "TDTXB", "教育科技學系", "教科系（日）", "TDTX", 'BC'],
          ["TKU", "TDTXM", "教育科技學系碩士班", "教科系碩士班", "TDTX", 'MC'],
          ["TKU", "TDTXJ", "教育科技學系碩士在職專班", "教科系碩專班", "TDTX", 'JC'],
          ["TKU", "TDTAJ", "教育科技學系數位碩士在職專班", "教科系數位碩專班", "TDTX", 'JC'],

          ["TKU", "TDPX",  "教育政策與領導研究所", "教政所", "TD", 'D'],
          ["TKU", "TDPXM", "教育政策與領導研究所碩士班", "教政所碩士班", "TDPX", 'MC'],
          ["TKU", "TDPAM", "教育政策與領導研究所教管組", "教政所教管組", "TDPXM", 'G'],
          ["TKU", "TDPBM", "教育政策與領導研究所高教組", "教政所高教組", "TDPXM", 'G'],
          ["TKU", "TDPXJ", "教育政策與領導研究所碩士在職專班", "教政所碩專班", "TDPX", 'JC'],
          ["TKU", "TDXXD", "教管博士班", "教管博士班", "TD", 'DC'],

          ["TKU", "TDCX",  "教育心理與諮商研究所", "教心所", "TD", 'D'],
          ["TKU", "TDCXM", "教育心理與諮商研究所碩士班", "教心所碩士班", "TDCX", 'MC'],

          ["TKU", "TDDX",  "未來學研究所", "未來學所", "TD", 'D'],
          ["TKU", "TDDXM", "未來學研究所碩士班", "未來學所碩士班", "TDDX", 'MC'],

          ["TKU", "TDIX",  "課程與教學研究所", "課程與教學研究所", "TD", 'D'],
          ["TKU", "TDIXM", "課程與教學研究所碩士班", "課程所碩士班", "TDIX", 'MC'],
          ["TKU", "TDIXJ", "課程與教學研究所碩士在職專班", "課程所碩士專班", "TDIX", 'JC'],

          ["TKU", "TDQBB", "中學教育學程", "中學教育學程", "TD", 'P'],

          # ["TKU", "065", "師資培育中心", "師資培育中心", "TD", 'D'],
          # ["TKU", "066", "通識與核心課程中心", "通識與核心課程中心", "TD", 'D'],

          ["TKU", "TQIX", "資訊創新與科技學系", "資創系", "TQ", 'D'],
          ["TKU", "TQIXB", "資訊創新與科技學系學士班", "資創系（日）", "TQIX", 'BC'],
          ["TKU", "TQIAB", "資訊創新與科技學系學士班軟工組", "資創系軟工組－日", "TQIXB", 'G'],
          ["TKU", "TQIBB", "資訊創新與科技學系學士班應資組", "資創系應資組－日", "TQIXB", 'G'],

          ["TKU", "TQVX", "國際觀光管理學系", "觀光系", "TQ", 'D'],
          ["TKU", "TQVXB", "國際觀光管理學系學士班", "觀光系（日）", "TQVX", 'BC'],

          ["TKU", "TQAX", "英美語言文化學系", "語言系", "TQ", 'D'],
          ["TKU", "TQAXB", "英美語言文化學系全英語學士班", "語言系（日）", "TQAX", 'BC'],

          ["TKU", "TQGX", "全球政治經濟學系", "政經系", "TQ", 'D'],
          ["TKU", "TQGXB", "全球政治經濟學系全英語學士班", "政經系（日）", "TQGX", 'D'],
        ], :validate => false
      )

      if tku.email_patterns.count < 1
        create(:tku_student_email_pattern)
        create(:tku_staff_email_pattern)
      end
    end
  end

  factory :tku_student_email_pattern, parent: :email_pattern do
    priority 15
    organization { Organization.find_by(code: 'TKU') || create(:tku_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:student]
    email_regexp '^(?<uid>.+)@s(?<started_at>\\d{2})\\.tku\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    started_at_postparser "new Date((parseInt(n)+1911+100) + '-9')"
    permit_changing_department_in_organization true
  end

  factory :tku_staff_email_pattern, parent: :email_pattern do
    priority 100
    organization { Organization.find_by(code: 'TKU') || create(:tku_organization) }
    corresponded_identity UserIdentity::IDENTITIES[:staff]
    email_regexp '^(?<uid>.+)@mail\\.tku\\.edu\\.tw$'
    uid_postparser "n.toLowerCase()"
    permit_changing_department_in_organization true
  end
end
