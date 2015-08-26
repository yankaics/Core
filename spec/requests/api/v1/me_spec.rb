require "rails_helper"

describe "Me API" do
  context "requested with no token" do
    it "returns error" do
      get '/api/v1/me.json'
      expect(response).not_to be_success
    end
  end

  context "GET" do
    context "requested with a access token contains public scope" do
      before do
        @token = create(:oauth_access_token)
      end

      it "returns the data of current user" do
        get "/api/v1/me.json?access_token=#{@token.token}"

        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['name']).to eq @token.resource_owner.name
        expect(json['id']).not_to be_blank
        expect(json['uuid']).not_to be_blank
        expect(json).not_to have_key 'email'
        expect(json).not_to have_key 'updated_at'
        expect(json).not_to have_key 'fbid'
        expect(json).not_to have_key 'brief'
        expect(json).not_to have_key 'organization'
      end
    end

    {
      'email' => %w(email),
      'account' => %w(sign_in_count last_sign_in_at),
      'facebook' => %w(fbid),
      'info' => %w(birth_month motto),
      'identity' => %w(emails identities organizations uid identity organization department organization_code department_code)
    }.each do |scope, attrs|

      context "requested with a access token contains #{scope} scope" do
        before do
          @token = create(:oauth_access_token, scopes: "public #{scope}")
        end

        attrs.each do |attr|
          it "returns the #{attr} of current user" do
            get "/api/v1/me.json?access_token=#{@token.token}"

            expect(response).to be_success
            json = JSON.parse(response.body)
            expect(json).to have_key attr
          end
        end
      end
    end

    context "requested with a access token having core powers" do
      before do
        @token = create(:oauth_access_token, :core, resource_owner_id: create(:user, :with_identity).id)
      end

      it "includes the user's emails, primary_identity and identities by default" do
        get "/api/v1/me.json?access_token=#{@token.token}"
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['emails'].first).to be_a(Hash)
        expect(json['primary_identity']).to be_a(Hash)
        expect(json['identities'].first).to be_a(Hash)
        expect(json['_meta']['relations']['emails']).to be_blank
        expect(json['_meta']['relations']['primary_identity']).to be_blank
        expect(json['_meta']['relations']['identities']).to be_blank
      end

      it "inclusion can be set to none" do
        get "/api/v1/me.json?access_token=#{@token.token}&include=none"
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['emails'].first).to be_a(Integer)
        expect(json['primary_identity']).to be_a(Integer)
        expect(json['identities'].first).to be_a(Integer)
        expect(json['_meta']['relations']['emails']['type']).to eq('user_email')
        expect(json['_meta']['relations']['primary_identity']['type']).to eq('user_identity')
        expect(json['_meta']['relations']['identities']['type']).to eq('user_identity')
      end
    end
  end

  context "PATCH" do
    context "requested with a access token contains public scope" do
      before do
        @token = create(:oauth_access_token)
      end

      it "fails" do
        patch "/api/v1/me.json?access_token=#{@token.token}&user[username]=wahaha&user[gender]=male&user[birth_year]=1994&user[birth_month]=1&&user[birth_day]=1"

        expect(response).not_to be_success
      end
    end

    context "requested with a access token contains write scope" do
      before do
        @token = create(:oauth_access_token, scopes: 'public write')
      end

      it "updates the user's data" do
        patch "/api/v1/me.json?access_token=#{@token.token}&user[username]=wahaha&user[gender]=male&user[birth_year]=1994&user[birth_month]=1&&user[birth_day]=1"

        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['username']).to eq('wahaha')
        user = User.find(json['id'])
        expect(user.username).to eq('wahaha')
        expect(user.gender).to eq('unspecified')
        expect(user.birth_year).not_to eq(1994)
      end
    end

    context "requested with a access token with public, info and write scope" do
      before do
        @token = create(:oauth_access_token, scopes: 'public info write')
      end

      it "updates the user's data" do
        patch "/api/v1/me.json?access_token=#{@token.token}&user[username]=wahaha&user[gender]=male&user[birth_year]=1994&user[birth_month]=1&&user[birth_day]=1"

        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json['username']).to eq('wahaha')
        user = User.find(json['id'])
        expect(user.username).to eq('wahaha')
        expect(user.gender).to eq('male')
        expect(user.birth_year).to eq(1994)
        expect(user.birth_month).to eq(1)
        expect(user.birth_day).to eq(1)
      end

      it "fails if parameters are invalid" do
        patch "/api/v1/me.json?access_token=#{@token.token}&user[birth_day]=100"
        expect(response).not_to be_success
        patch "/api/v1/me.json?access_token=#{@token.token}&user[gender]=ahg"
        expect(response).not_to be_success
      end
    end
  end

  describe "/devices" do
    before do
      @token = create(:oauth_access_token, scopes: 'public account write')
      @user = @token.resource_owner
      @device = create(:user_device, user: @user)
    end

    context "GET" do
      it "returns data of the user's devices" do
        get "/api/v1/me/devices.json?access_token=#{@token.token}"
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json[0]).not_to be_blank
      end
    end

    context "POST" do
      it "creates the user's new devices" do
        post "/api/v1/me/devices.json?access_token=#{@token.token}",
             user_device: {
               type: 'android',
               name: 'HTC',
               device_id: '1234'
             }
        expect(response).to be_success
        expect(response.code).to eq('201')
        json = JSON.parse(response.body)
        expect(json['name']).to eq('HTC')
        expect(json['device_id']).to eq('1234')
      end
    end
  end

  describe "/devices/{uuid}" do
    before do
      @token = create(:oauth_access_token, scopes: 'public account write')
      @user = @token.resource_owner
      @device = create(:user_device, user: @user)
    end

    context "PUT" do
      it "creates the user's new device" do
        put "/api/v1/me/devices/u-u-i-d.json?access_token=#{@token.token}",
            user_device: {
              type: 'android',
              name: 'HTC',
              device_id: '1234'
            }
        expect(response).to be_success
        expect(response.code).to eq('201')
        json = JSON.parse(response.body)
        expect(json['name']).to eq('HTC')
        expect(json['uuid']).to eq('u-u-i-d')
        expect(json['device_id']).to eq('1234')
      end

      it "replaces data of the user's existing device" do
        put "/api/v1/me/devices/#{@device.uuid}.json?access_token=#{@token.token}",
            user_device: {
              type: 'ios',
              name: 'My iPhone 7',
              device_id: '1234'
            }
        expect(response).to be_success
        expect(response.code).to eq('200')
        json = JSON.parse(response.body)
        expect(json['uuid']).not_to be_blank
        expect(json['name']).to eq('My iPhone 7')
        expect(json['device_id']).to eq('1234')
      end
    end

    context "DELETE" do
      it "delete the user's device" do
        delete "/api/v1/me/devices/#{@device.uuid}.json?access_token=#{@token.token}"
        expect(response).to be_success
        expect(response.code).to eq('200')
        json = JSON.parse(response.body)
        expect(json['uuid']).not_to be_blank

        expect(UserDevice.find_by(uuid: @device.uuid)).to be_blank
      end
    end
  end
end
