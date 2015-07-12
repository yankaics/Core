require "rails_helper"

describe "Users API" do
  let(:premitted_app) { create(:oauth_application, allow_direct_data_access: true) }
  let(:unpremitted_app) { create(:oauth_application) }
  before do
    create_list :user, 10
  end

  context "requested with no token" do
    it "fails" do
      get "/api/v1/users.json"
      expect(response).not_to be_success
      get "/api/v1/users/#{User.last.id}.json"
      expect(response).not_to be_success
      patch "/api/v1/users/#{User.last.id}.json", 'user[username]' => 'hi'
      expect(response).not_to be_success
    end
  end

  context "requested with an unpremitted app token" do
    it "fails" do
      post '/oauth/token', grant_type: 'client_credentials',
                           client_id: unpremitted_app.uid,
                           client_secret: unpremitted_app.secret
      expect(response).to be_success
      json = JSON.parse(response.body)
      access_token = json['access_token']

      get "/api/v1/users.json?access_token=#{access_token}"
      expect(response).not_to be_success
      get "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}"
      expect(response).not_to be_success
      patch "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}", 'user[username]' => 'hi'
      expect(response).not_to be_success
    end
  end

  context "requested with an premitted app token" do
    it "successes" do
      post '/oauth/token', grant_type: 'client_credentials',
                           client_id: premitted_app.uid,
                           client_secret: premitted_app.secret
      expect(response).to be_success
      json = JSON.parse(response.body)
      access_token = json['access_token']

      get "/api/v1/users.json?access_token=#{access_token}"
      expect(response).to be_success
      get "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}"
      expect(response).to be_success
      patch "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}", 'user[username]' => 'hi'
      expect(response).to be_success
    end
  end

  context "requested with an premitted app user token" do
    it "fails" do
      access_token = create(:oauth_access_token, application: premitted_app, resource_owner_id: User.last.id).token

      get "/api/v1/users.json?access_token=#{access_token}"
      expect(response).not_to be_success
      get "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}"
      expect(response).not_to be_success
      patch "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}", 'user[username]' => 'hi'
      expect(response).not_to be_success
    end
  end

  context "GET users" do
    it "returns data of users" do
      access_token = create(:oauth_access_token, application: premitted_app, resource_owner_id: nil).token
      get "/api/v1/users.json?access_token=#{access_token}"

      expect(response).to be_success
      json = JSON.parse(response.body)
    end
  end

  context "GET users/:id" do
    it "returns data of a user" do
      access_token = create(:oauth_access_token, application: premitted_app, resource_owner_id: nil).token
      get "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}"

      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('id')
    end
  end

  context "PATCH users/:id" do
    it "updates data for a user" do
      access_token = create(:oauth_access_token, application: premitted_app, resource_owner_id: nil).token
      url = "/api/v1/users/#{User.last.id}.json?access_token=#{access_token}"
      patch url, 'user[username]' => 'hi',
                 'user[name]' => 'Yo Ya',
                 'user[gender]' => 'female',
                 'user[birth_year]' => '1994',
                 'user[birth_month]' => '5',
                 'user[birth_day]' => '18',
                 'user[brief]' => 'brief',
                 'user[motto]' => 'motto',
                 'user[url]' => 'url'

      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json).to have_key('id')

      user = User.last

      expect(json['username']).to eq('hi')
      expect(user['username']).to eq('hi')
      expect(json['username']).to eq('hi')
      expect(user['username']).to eq('hi')
      expect(json['name']).to eq('Yo Ya')
      expect(user['name']).to eq('Yo Ya')
      expect(json['gender']).to eq('female')
      expect(user.gender).to eq('female')
      expect(json['birth_year']).to eq(1994)
      expect(user.birth_year).to eq(1994)
      expect(json['birth_month']).to eq(5)
      expect(user.birth_month).to eq(5)
      expect(json['birth_day']).to eq(18)
      expect(user.birth_day).to eq(18)
      expect(json['brief']).to eq('brief')
      expect(user.brief).to eq('brief')
      expect(json['motto']).to eq('motto')
      expect(user.motto).to eq('motto')
      expect(json['url']).to eq('url')
      expect(user.url).to eq('url')
    end
  end
end
