require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:application) }

  describe "#click!" do
    let(:user) { create(:user) }

    it "marks the notification as clicked" do
      notification = user.notifications.create(message: 'hi')
      expect(notification.clicked_at).to be_blank

      click_notification = notification.click!

      expect(notification.clicked_at).not_to be_blank
      notification.reload
      expect(notification.clicked_at).not_to be_blank

      expect(click_notification).to eq(notification)
    end
  end
end
