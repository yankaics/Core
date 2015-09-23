require "rails_helper"

describe "SMS API" do
  describe "POST /api/v1/sms" do
    let(:application) { create(:oauth_application) }
    let(:app_access_token) { create(:oauth_access_token, application: application, resource_owner_id: 0) }
    let(:user_access_token) { create(:oauth_access_token, application: application) }

    context "with an application access token with remaining SMS quota" do
      before do
        application.sms_quota = 10
        application.save!
      end

      it "successes" do
        token = app_access_token.token
        post "/api/v1/sms.json?access_token=#{token}", sms: { to: '0900000000',
                                                              text: 'Hello World' }

        expect(response).to be_success
        json = JSON.parse(response.body)

        expect(json['to']).to eq('+886900000000')

        application.reload
        expect(application.sms_quota).to eq(9)
      end
    end

    context "with an application access token with no remaining SMS quota" do
      before do
        application.sms_quota = 0
        application.save!
      end

      it "fails" do
        token = app_access_token.token
        post "/api/v1/sms.json?access_token=#{token}", sms: { to: '0900000000',
                                                              text: 'Hello World' }

        expect(response).not_to be_success
      end
    end

    context "with an user access token" do
      before do
        application.sms_quota = 10
        application.save!
      end

      it "fails" do
        token = user_access_token.token
        post "/api/v1/sms.json?access_token=#{token}", sms: { to: '0900000000',
                                                              text: 'Hello World' }

        expect(response).not_to be_success
      end
    end
  end
end
