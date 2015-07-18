require 'rails_helper'

RSpec.describe UserFacebookSyncJob, type: :job do
  it "calls the #facebook_sync method on an user" do
    user = double("user")
    expect(user).to receive(:facebook_sync)
    UserFacebookSyncJob.perform_now(user)
  end
end
