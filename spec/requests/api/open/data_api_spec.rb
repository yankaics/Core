require "rails_helper"

describe "Open Data API" do
  let(:data_api) do
    create(:data_api, :with_data, data_count: 32, path: 'path/to/data_api',
                                  schema: { string_col: { type: 'string' },
                                            integer_col: { type: 'integer' } })
  end
  let(:another_data_api) do
    create(:data_api, :with_data, data_count: 10, path: 'path/to/another_data_api',
                                  primary_key: :integer_col,
                                  schema: { string_col: { type: 'string' },
                                            integer_col: { type: 'integer' },
                                            float_col: { type: 'float' },
                                            boolean_col: { type: 'boolean' },
                                            text_col: { type: 'text' },
                                            datetime_col: { type: 'datetime' } })
  end
  let(:yet_another_data_api) do
    data_api = create(:data_api, path: 'path/to/yet_another_data_api',
                                 default_order: 'a ASC',
                                 schema: { a: { type: 'string' },
                                           b: { type: 'string' },
                                           c: { type: 'string' } })
    data_api.data_model.create!(a: '1', b: 'alpha', c: 'alpha')
    data_api.data_model.create!(a: '2', b: 'alpha', c: 'beta')
    data_api.data_model.create!(a: '3', b: 'beta', c: 'alpha')
    data_api.data_model.create!(a: '4', b: 'beta', c: 'beta')
    data_api
  end
  let(:user) do
    create(:user, :confirmed, :with_identity)
  end
  let(:user2) do
    create(:user, :confirmed, :with_identity)
  end
  let(:private_user_data_api) do
    data_api = create(:data_api, path: 'path/to/private_user_data_api',
                                 public: false,
                                 schema: { user_id: { type: 'string' },
                                           user_uuid: { type: 'string' },
                                           user_email: { type: 'string' },
                                           user_uid: { type: 'string' } })
    data_api.data_model.create!(user_id: user.id, user_uuid: user.uuid, user_email: user.email, user_uid: user.uid)
    data_api.data_model.create!(user_id: user2.id, user_uuid: user2.uuid, user_email: user2.email, user_uid: user2.uid)
    data_api
  end
  let(:not_accessible_data_api) do
    create(:data_api, path: 'path/to/private_user_data_api',
                             accessible: false,
                             schema: { a: { type: 'string' },
                                       b: { type: 'string' },
                                       c: { type: 'string' } })
  end

  it "can be accessed with no versioning info provided" do
    get "/api/v1/#{data_api.path}.json"
    versioned_response = response
    get "/api/#{data_api.path}.json"
    unversioned_response = response
    expect(versioned_response.body).to eq(unversioned_response.body)
  end

  describe "unaccessible (not-opened) API" do
    it "is not accessible" do
      get "/api/v1/#{not_accessible_data_api.path}.json"
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('error')
    end
  end

  describe "private API" do
    it "is not accessible by public URL" do
      get "/api/v1/#{private_user_data_api.path}.json"
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('error')
    end
  end

  describe "resource collection" do
    it "returns datas" do
      get "/api/v1/#{data_api.path}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      last_data = data_api.data_model.last
      expect(json).to include({ 'id' => last_data.id, 'string_col' => last_data.string_col, 'integer_col' => last_data.integer_col, '_type' => data_api.name })
    end

    it "is fieldsettable" do
      last_data = another_data_api.data_model.last
      get "/api/v1/#{another_data_api.path}.json?fields=string_col,integer_col"
      expect(response).to be_success
      expect(response.body).to include(last_data.string_col)
      expect(response.body).to include("#{last_data.integer_col}")
      expect(response.body).not_to include(last_data.text_col)

      get "/api/v1/#{another_data_api.path}.json?fields=text_col"
      expect(response).to be_success
      expect(response.body).not_to include(last_data.string_col)
      expect(response.body).to include(last_data.text_col)
    end

    it "is paginated" do
      get "/api/v1/#{data_api.path}.json?per_page=10&page=1"
      expect(response).to be_success
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=10&page=2")
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=10&page=4")
      expect(response.body).to include(data_api.data_model.last.string_col)
      expect(response.body).not_to include(data_api.data_model.first.string_col)

      get "/api/v1/#{data_api.path}.json?per_page=10&page=2"
      expect(response).to be_success
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=10&page=1")
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=10&page=3")
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=10&page=4")
      expect(response.body).not_to include(data_api.data_model.last.string_col)
      expect(response.body).not_to include(data_api.data_model.first.string_col)

      get "/api/v1/#{data_api.path}.json?per_page=5&page=5"
      expect(response).to be_success
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=5&page=1")
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=5&page=4")
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=5&page=6")
      expect(response.headers['Link']).to include("/api/v1/#{data_api.path}.json?per_page=5&page=7")
    end

    it "is sortable" do
      get "/api/v1/#{yet_another_data_api.path}.json"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.map { |v| v['a'] }).to eq(["1", "2", "3", "4"])

      get "/api/v1/#{yet_another_data_api.path}.json?sort=b,-a"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.map { |v| v['a'] }).to eq(["2", "1", "4", "3"])

      get "/api/v1/#{yet_another_data_api.path}.json?sort_by=-b,c"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.map { |v| v['a'] }).to eq(["3", "4", "1", "2"])

      get "/api/v1/#{yet_another_data_api.path}.json?sort_by=c%2C+-b+%27+%5C%22+%21%40%23%24%25%5E%26%2A"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.map { |v| v['a'] }).to eq(["3", "1", "4", "2"])
    end
  end

  describe "single resource" do
    it "returns a data" do
      first_data = data_api.data_model.first
      get "/api/v1/#{data_api.path}/#{first_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json).to eq({ 'id' => first_data.id, 'string_col' => first_data.string_col, 'integer_col' => first_data.integer_col, '_type' => data_api.name })

      second_data = another_data_api.data_model.second
      get "/api/v1/#{another_data_api.path}/#{second_data.integer_col}.json"
      expect(response).to be_success
      expect(response.body).to include(second_data.text_col)
    end

    it "is fieldsettable" do
      last_data = another_data_api.data_model.last
      get "/api/v1/#{another_data_api.path}/#{last_data.integer_col}.json?fields=string_col,integer_col"
      expect(response).to be_success
      expect(response.body).to include(last_data.string_col)
      expect(response.body).to include("#{last_data.integer_col}")
      expect(response.body).not_to include(last_data.text_col)

      get "/api/v1/#{another_data_api.path}/#{last_data.integer_col}.json?fields=text_col"
      expect(response).to be_success
      expect(response.body).not_to include(last_data.string_col)
      expect(response.body).to include(last_data.text_col)
    end
  end
end
