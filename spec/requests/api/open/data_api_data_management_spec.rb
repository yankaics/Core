require "rails_helper"

describe "Open Data API - Data Management" do
  let(:data_api) do
    create(:data_api, :with_data, data_count: 32, path: 'path/to/a_data_api',
                                  primary_key: :string_col,
                                  schema: { string_col: { type: 'string', index: true },
                                            integer_col: { type: 'integer' },
                                            float_col: { type: 'float' },
                                            boolean_col: { type: 'boolean' },
                                            text_col: { type: 'text' },
                                            datetime_col: { type: 'datetime' } })
  end
  let(:private_user_data_api) do
    create(:data_api, path: 'path/to/private_user_data_api',
                      public: false,
                      owned_by_user: true,
                      owner_primary_key: 'id',
                      owner_foreign_key: 'user_id',
                      schema: { user_id: { type: 'string' },
                                user_uuid: { type: 'string' },
                                user_email: { type: 'string' },
                                user_uid: { type: 'string' },
                                datetime: { type: 'datetime' },
                                data: { type: 'text' } })
  end
  let(:not_accessible_data_api) do
    create(:data_api, path: 'path/to/not_opened_data_api',
                      accessible: false,
                      schema: { a: { type: 'string' },
                                b: { type: 'string' },
                                c: { type: 'string' } })
  end

  it "can't be used without a vaild key" do
    get "/api/data_management/#{data_api.path}.json"
    expect(response).not_to be_success
    get "/api/data_management/#{data_api.path}.json?key=ooxx"
    expect(response).not_to be_success
  end

  it "can be used with a vaild key" do
    get "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success

    get "/api/data_management/#{private_user_data_api.path}.json?key=#{private_user_data_api.management_api_key}"
    expect(response).to be_success

    get "/api/data_management/#{not_accessible_data_api.path}.json?key=#{not_accessible_data_api.management_api_key}"
    expect(response).to be_success
  end

  it "GETs data" do
    get "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    json = JSON.parse(response.body)

    get "/api/data_management/#{data_api.path}/1.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    json = JSON.parse(response.body)
  end

  it "POSTs data" do
    post "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}",
         data_api.name => {
           string_col: 'hello_world',
           integer_col: 12,
           float_col: 3.1415926,
           boolean_col: true,
           text_col: 'When there\'s a will, there\'s a way.',
           datetime_col: Time.now
         }
    expect(response).to be_success
    json = JSON.parse(response.body)
    primary_key = json[data_api.primary_key]

    get "/api/data_management/#{data_api.path}/#{URI.encode(primary_key)}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json['string_col']).not_to be_blank
    expect(json['integer_col']).not_to be_blank
    expect(json['float_col']).not_to be_blank
    expect(json['boolean_col']).not_to be_blank
    expect(json['text_col']).not_to be_blank
    expect(json['datetime_col']).not_to be_blank
  end

  it "PATCHs data" do
    id = data_api.data_model.last.id
    patch "/api/data_management/#{data_api.path}/#{id}.json?key=#{data_api.management_api_key}",
          data_api.name => {
            text_col: 'hi',
            datetime_col: Time.now
          }
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json['text_col']).to eq('hi')
    expect(json['integer_col']).not_to be_blank
    expect(json['float_col']).not_to be_blank
    expect(json['datetime_col']).not_to be_blank

    get "/api/data_management/#{data_api.path}/#{id}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json['text_col']).not_to be_blank
    expect(json['integer_col']).not_to be_blank
    expect(json['float_col']).not_to be_blank
    expect(json['datetime_col']).not_to be_blank
  end

  it "PUTs data" do
    # Replace
    primary_key = data_api.data_model.last[data_api.primary_key]
    put "/api/data_management/#{data_api.path}/#{URI.encode(primary_key)}.json?key=#{data_api.management_api_key}",
        data_api.name => {
          text_col: 'hi',
          datetime_col: Time.now
        }
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json[data_api.primary_key]).not_to be_blank
    expect(json['text_col']).to eq('hi')
    expect(json['integer_col']).to be_blank
    expect(json['float_col']).to be_blank
    expect(json['datetime_col']).not_to be_blank

    get "/api/data_management/#{data_api.path}/#{URI.encode(primary_key)}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    expect(response.code).to eq('200')
    json = JSON.parse(response.body)
    expect(json[data_api.primary_key]).not_to be_blank
    expect(json['text_col']).to eq('hi')
    expect(json['integer_col']).to be_blank
    expect(json['float_col']).to be_blank
    expect(json['datetime_col']).not_to be_blank

    # Or Create
    put "/api/data_management/#{data_api.path}/hello.json?key=#{data_api.management_api_key}",
        data_api.name => {
          text_col: 'Hello World',
          datetime_col: Time.now
        }
    expect(response).to be_success
    expect(response.code).to eq('201')
    json = JSON.parse(response.body)
    expect(json['text_col']).to eq('Hello World')
    expect(json[data_api.primary_key]).to eq('hello')
    expect(json['datetime_col']).not_to be_blank

    get "/api/data_management/#{data_api.path}/hello.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json['text_col']).to eq('Hello World')
    expect(json[data_api.primary_key]).to eq('hello')
    expect(json['datetime_col']).not_to be_blank
  end

  it "DELETEs data" do
    # Deletes Single Data
    primary_key = data_api.data_model.last[data_api.primary_key]

    get "/api/data_management/#{data_api.path}/#{URI.encode(primary_key)}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success

    delete "/api/data_management/#{data_api.path}/#{URI.encode(primary_key)}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success

    get "/api/data_management/#{data_api.path}/#{URI.encode(primary_key)}.json?key=#{data_api.management_api_key}"
    expect(response).not_to be_success

    # Deletes Multiple Data
    primary_keys = [
      data_api.data_model.first[data_api.primary_key],
      data_api.data_model.last[data_api.primary_key]
    ]

    get "/api/data_management/#{data_api.path}/#{primary_keys.first}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success
    get "/api/data_management/#{data_api.path}/#{primary_keys.last}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success

    delete "/api/data_management/#{data_api.path}/#{primary_keys.join(',')}.json?key=#{data_api.management_api_key}"
    expect(response).to be_success

    get "/api/data_management/#{data_api.path}/#{primary_keys.first}.json?key=#{data_api.management_api_key}"
    expect(response).not_to be_success
    get "/api/data_management/#{data_api.path}/#{primary_keys.last}.json?key=#{data_api.management_api_key}"
    expect(response).not_to be_success

    # Deletes Scope of Data
    false_datas_for_retention = data_api.data_model.where(boolean_col: false)[0..2]
    false_data_string_cols_for_retention = false_datas_for_retention.map(&:string_col)

    delete "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}&filter[boolean_col]=false&filter[string_col]=not(#{false_data_string_cols_for_retention.join(',')})"
    expect(response).to be_success

    get "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}&filter[boolean_col]=false&filter[string_col]=not(#{false_data_string_cols_for_retention.join(',')})"
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json.count).to eq(0)

    get "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}&filter[boolean_col]=false"
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json.count).to eq(3)

    get "/api/data_management/#{data_api.path}.json?key=#{data_api.management_api_key}&filter[boolean_col]=true&filter[string_col]=not(#{false_data_string_cols_for_retention.join(',')})"
    expect(response).to be_success
    json = JSON.parse(response.body)
    expect(json).not_to be_blank
  end
end
