require "rails_helper"

describe "Open Data API" do
  let(:data_api) do
    create(:data_api, :with_data, data_count: 32, path: 'path/to/data_api',
                                  schema: { string_col: { type: 'string' },
                                            integer_col: { type: 'integer' } })
  end
  let(:another_data_api) do
    create(:data_api, :with_data, data_count: 12, path: 'path/to/another_data_api',
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
                                 owned_by_user: true,
                                 owner_primary_key: 'id',
                                 owner_foreign_key: 'user_id',
                                 organization_code: user.organization_code,
                                 schema: { user_id: { type: 'string' },
                                           user_uuid: { type: 'string' },
                                           user_email: { type: 'string' },
                                           user_uid: { type: 'string' },
                                           datetime: { type: 'datetime' },
                                           data: { type: 'text' } })
    data_api.data_model.create!(user_id: user.id, user_uuid: user.uuid, user_email: user.email, user_uid: user.uid)
    data_api.data_model.create!(user_id: user2.id, user_uuid: user2.uuid, user_email: user2.email, user_uid: user2.uid)
    data_api
  end
  let(:not_accessible_data_api) do
    create(:data_api, path: 'path/to/not_opened_data_api',
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
    let(:core_access_token) { create(:oauth_access_token, :core).token }

    it "is not accessible" do
      get "/api/v1/#{not_accessible_data_api.path}.json"
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('error')
    end

    it "is accessible via core apps" do
      get "/api/v1/#{not_accessible_data_api.path}.json?access_token=#{core_access_token}"
      expect(response).to be_success
      json = JSON.parse(response.body)
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

    it "is filterable" do
      get "/api/v1/#{another_data_api.path}.json?filter[boolean_col]=true"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data).not_to be_blank
      response_data.each do |data|
        expect(data['boolean_col']).to be true
      end

      get "/api/v1/#{another_data_api.path}.json?filter[boolean_col]=not(true)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data).not_to be_blank
      response_data.each do |data|
        expect(data['boolean_col']).to be false
      end

      get "/api/v1/#{another_data_api.path}.json?filter[boolean_col]=not(true,false)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data).to be_blank

      get "/api/v1/#{another_data_api.path}.json?filter[boolean_col]=true,false"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.count).to eq(12)

      get "/api/v1/#{another_data_api.path}.json?filter[float_col]=greater_then(5)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      response_data.each do |data|
        expect(data['float_col']).to be > 5
      end

      get "/api/v1/#{another_data_api.path}.json?filter[id]=greater_then_or_equal(5)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data).not_to be_blank
      response_data.each do |data|
        expect(data['id']).to be >= 5
      end

      get "/api/v1/#{another_data_api.path}.json?filter[float_col]=less_then(5)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      response_data.each do |data|
        expect(data['float_col']).to be < 5
      end

      get "/api/v1/#{another_data_api.path}.json?filter[id]=less_then_or_equal(5)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data).not_to be_blank
      response_data.each do |data|
        expect(data['id']).to be <= 5
      end

      get "/api/v1/#{another_data_api.path}.json?filter[id]=between(3,7)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.count).to eq(5)
      response_data.each do |data|
        expect(data['id']).to be >= 3
        expect(data['id']).to be <= 7
      end

      get "/api/v1/#{another_data_api.path}.json?filter[text_col]=like(%25(7))"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.first['text_col'][-3..-1]).to eq('(7)')

      get "/api/v1/#{another_data_api.path}.json?filter[datetime_col]=between(1800-1-1,8000-1-1)"
      expect(response).to be_success
      response_data = JSON.parse(response.body)
      expect(response_data.count).to eq(12)
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

    it "can have a owner" do
      private_user_data_api.public = true
      private_user_data_api.save!

      get "/api/v1/#{private_user_data_api.path}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.last['owner']).to eq(user.id.to_s)

      get "/api/v1/#{private_user_data_api.path}.json?include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.first['owner']).to have_key('name')
      expect(json.first['owner']).not_to have_key('email')
      expect(json.last['owner']['name']).to eq(user.name)

      private_user_data_api.owner_primary_key = 'uuid'
      private_user_data_api.owner_foreign_key = 'user_uuid'
      private_user_data_api.save!

      get "/api/v1/#{private_user_data_api.path}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.last['owner']).to eq(user.uuid)

      get "/api/v1/#{private_user_data_api.path}.json?include=owner&fields=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.first['owner']).to have_key('name')
      expect(json.first['owner']).not_to have_key('email')
      expect(json.last['owner']['name']).to eq(user.name)

      get "/api/v1/#{private_user_data_api.path}.json?include=owner&fields[#{private_user_data_api.name}]=owner&fields[user]=username,uuid,avatar_url"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.first['owner']).to have_key('username')
      expect(json.first).not_to have_key('data')
    end
  end

  describe "specified resource" do
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

    it "is multigettable" do
      first_data = another_data_api.data_model.first
      last_data = another_data_api.data_model.last
      get "/api/v1/#{another_data_api.path}/#{last_data.integer_col},#{first_data.integer_col}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.count).to eq(2)
      expect(json.first['string_col']).to eq(first_data.string_col)
      expect(json.last['string_col']).to eq(last_data.string_col)
    end

    it "fallbacks to use the id field to find a resourse" do
      first_data = another_data_api.data_model.first
      last_data = another_data_api.data_model.last
      get "/api/v1/#{another_data_api.path}/#{last_data.id},#{first_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.count).to eq(2)
      expect(json.first['string_col']).to eq(first_data.string_col)
      expect(json.last['string_col']).to eq(last_data.string_col)
    end

    it "can have a owner" do
      private_user_data_api.public = true
      private_user_data_api.save!

      first_data = private_user_data_api.data_model.first
      last_data = private_user_data_api.data_model.last

      get "/api/v1/#{private_user_data_api.path}/#{first_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']).to eq(user.id.to_s)

      get "/api/v1/#{private_user_data_api.path}/#{last_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']).to eq(user2.id.to_s)

      get "/api/v1/#{private_user_data_api.path}/#{first_data.id}.json?include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']['username']).to eq(user.username)

      get "/api/v1/#{private_user_data_api.path}/#{last_data.id}.json?include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']['username']).to eq(user2.username)

      private_user_data_api.owner_primary_key = 'uid'
      private_user_data_api.owner_foreign_key = 'user_uid'
      private_user_data_api.save!

      get "/api/v1/#{private_user_data_api.path}/#{first_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']).to eq(user.uid)

      get "/api/v1/#{private_user_data_api.path}/#{last_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']).to eq(user2.uid)

      get "/api/v1/#{private_user_data_api.path}/#{first_data.id}.json?include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']['username']).to eq(user.username)

      get "/api/v1/#{private_user_data_api.path}/#{last_data.id}.json?include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']).to be_nil
    end
  end

  describe "resourse scoped by user" do
    let(:access_token) { create(:oauth_access_token, scopes: 'api', resource_owner_id: user.id).token }
    let(:access_token2) { create(:oauth_access_token, scopes: 'api', resource_owner_id: user2.id).token }
    let(:writable_access_token) { create(:oauth_access_token, scopes: 'api api:write', resource_owner_id: user.id).token }
    let(:writable_access_token2) { create(:oauth_access_token, scopes: 'api api:write', resource_owner_id: user2.id).token }

    it "is not accessable without an valid access token" do
      get "/api/v1/me/#{private_user_data_api.path}.json"
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('error')
    end

    it "is accessable with an valid access token" do
      get "/api/v1/me/#{private_user_data_api.path}.json?access_token=#{access_token}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]['owner']['uuid']).to eq(user.uuid)

      # getting a single resource
      get "/api/v1/me/#{private_user_data_api.path}/1.json?access_token=#{access_token}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']['uuid']).to eq(user.uuid)

      get "/api/v1/me/#{private_user_data_api.path}/2.json?access_token=#{access_token2}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']['uuid']).to eq(user2.uuid)

      # 404 when getting a single resource not owned by the corresponding user
      get "/api/v1/me/#{private_user_data_api.path}/2.json?access_token=#{access_token}&include=owner"
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('error')

      # With uuid association link (uuid as the primary key)
      private_user_data_api.owner_primary_key = 'uuid'
      private_user_data_api.owner_foreign_key = 'user_uuid'
      private_user_data_api.save!

      get "/api/v1/me/#{private_user_data_api.path}.json?access_token=#{access_token}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]['owner']['uuid']).to eq(user.uuid)

      # With email association link (email as the primary key)
      private_user_data_api.owner_primary_key = 'email'
      private_user_data_api.owner_foreign_key = 'user_email'
      private_user_data_api.save!

      get "/api/v1/me/#{private_user_data_api.path}.json?access_token=#{access_token}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]['owner']['uuid']).to eq(user.uuid)

      get "/api/v1/me/#{private_user_data_api.path}.json?access_token=#{access_token2}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]['owner']['uuid']).to eq(user2.uuid)

      # With uid association link (uid as the primary key)
      private_user_data_api.owner_primary_key = 'uid'
      private_user_data_api.owner_foreign_key = 'user_uid'
      private_user_data_api.save!

      get "/api/v1/me/#{private_user_data_api.path}.json?access_token=#{access_token}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]['owner']['uuid']).to eq(user.uuid)

      # it is not cross-organization available
      get "/api/v1/me/#{private_user_data_api.path}.json?access_token=#{access_token2}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json).to be_blank

      # getting a single resource
      get "/api/v1/me/#{private_user_data_api.path}/1.json?access_token=#{access_token}&include=owner"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['owner']['uuid']).to eq(user.uuid)
    end

    it "is writeable while permitted" do
      # While API's owner_writable is false
      post "/api/me/#{private_user_data_api.path}.json?access_token=#{writable_access_token}",
        private_user_data_api.name => {
          datetime: '2014-9-9',
          data: 'hi'
        }
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json['error']).to eq(403)

      private_user_data_api.owner_writable = true
      private_user_data_api.save!

      # While API's owner_writable is true
      post "/api/me/#{private_user_data_api.path}.json?access_token=#{writable_access_token}",
        private_user_data_api.name => {
          datetime: '2014-9-9',
          data: 'hi'
        }
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['data']).to eq('hi')
      expect(json['datetime']).to start_with('2014-09-09 00:00:00')
      data_id = json['id']

      # With an access token without API write permission
      post "/api/me/#{private_user_data_api.path}.json?access_token=#{access_token}",
        private_user_data_api.name => {
          datetime: '2014-9-9',
          data: 'hi'
        }
      expect(response).not_to be_success
      json = JSON.parse(response.body)
      expect(json['error']).to eq('insufficient_scope')

      # Update
      patch "/api/me/#{private_user_data_api.path}/#{data_id}.json?access_token=#{writable_access_token}",
            private_user_data_api.name => {
              datetime: '2014/9/9 12:34'
            }
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['data']).to eq('hi')
      expect(json['datetime']).to start_with('2014-09-09 12:34:00')
      get "/api/me/#{private_user_data_api.path}/#{data_id}.json?access_token=#{writable_access_token}"
      expect(response).to be_success

      # Create or Replace
      put "/api/me/#{private_user_data_api.path}/1023.json?access_token=#{writable_access_token}",
          private_user_data_api.name => {
            data: 'hello',
            datetime: '2014/9/9 12:34'
          }
      expect(response).to be_success
      expect(response.status).to eq(201)  # created
      json = JSON.parse(response.body)
      expect(json['data']).to eq('hello')
      expect(json['datetime']).to start_with('2014-09-09 12:34:00')
      get "/api/me/#{private_user_data_api.path}/1023.json?access_token=#{writable_access_token}"
      expect(response).to be_success

      put "/api/me/#{private_user_data_api.path}/1023.json?access_token=#{writable_access_token2}",
          private_user_data_api.name => {
            data: 'hello',
            datetime: '2014/9/9 12:34'
          }
      expect(response).not_to be_success
      expect(response.status).to eq(400)  # duplicated primary key

      put "/api/me/#{private_user_data_api.path}/#{data_id}.json?access_token=#{writable_access_token}",
          private_user_data_api.name => {
            datetime: '2014/9/9 12:34'
          }
      expect(response).to be_success
      expect(response.status).to eq(200)  # updated
      json = JSON.parse(response.body)
      expect(json['data']).to be_blank  # because the whole object is replaced
      expect(json['datetime']).to start_with('2014-09-09 12:34:00')
      get "/api/me/#{private_user_data_api.path}/#{data_id}.json?access_token=#{writable_access_token}"
      expect(response).to be_success

      # Delete
      delete "/api/me/#{private_user_data_api.path}/#{data_id}.json?access_token=#{writable_access_token}"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['datetime']).to start_with('2014-09-09 12:34:00')
      get "/api/me/#{private_user_data_api.path}/#{data_id}.json?access_token=#{writable_access_token}"
      expect(response).not_to be_success
    end
  end
end
