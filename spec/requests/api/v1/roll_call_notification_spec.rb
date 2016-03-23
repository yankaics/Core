require "rails_helper"

describe "Roll Call Notification API" do
  let(:token) { create(:oauth_access_token) }

  describe "GET /api/v1/roll_call_notification" do
    context "there's no roll_call_notification for the specific course yet" do
      it "success" do
        get "/api/v1/roll_call_notification.json?access_token=#{token.token}", organization_code: 'organization_code', course_code: 'course_code'

        expect(response).to be_success
        expect(response.status).to eq(200)
      end
    end

    context "there's a roll_call_notification for the specific course" do
      before do
        RollCallNotification.create!(user_id: 1, organization_code: 'organization_code', course_code: 'course_code')
      end

      it "success and returns the time that the notification was sent" do
        get "/api/v1/roll_call_notification.json?access_token=#{token.token}", organization_code: 'organization_code', course_code: 'course_code'

        expect(response).to be_success
        expect(response.status).to eq(200)

        json = JSON.parse(response.body)
        expect(DateTime.parse(json['created_at']).to_i).to eq(RollCallNotification.last.created_at.to_i)
      end
    end
  end

  describe "POST /api/v1/roll_call_notification" do
    before do
      allow(MobileNotificationService).to receive(:send_roll_call_notification)
    end

    context "there's a roll_call_notification for the specific course created in 10 minutes" do
      before do
        RollCallNotification.create!(user_id: 1, organization_code: 'organization_code', course_code: 'course_code', created_at: 10.minutes.ago)
      end

      it "fails with status 400" do
        post "/api/v1/roll_call_notification.json?access_token=#{token.token}", organization_code: 'organization_code', course_code: 'course_code'

        expect(response).not_to be_success
        expect(response.status).to eq(400)
      end
    end

    context "there's a roll_call_notification for the specific course created over 21 minutes" do
      before do
        RollCallNotification.create!(user_id: 1, organization_code: 'organization_code', course_code: 'course_code', created_at: 21.minutes.ago)
      end

      it "success with status 201" do
        post "/api/v1/roll_call_notification.json?access_token=#{token.token}", organization_code: 'organization_code', course_code: 'course_code'

        expect(response).to be_success
        expect(response.status).to eq(201)
      end
    end

    it "logs the user's id" do
      post "/api/v1/roll_call_notification.json?access_token=#{token.token}", organization_code: 'organization_code', course_code: 'course_code'

      expect(RollCallNotification.last.user_id).to eq(token.resource_owner_id)
    end
  end
end
