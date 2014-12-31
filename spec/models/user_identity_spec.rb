require 'rails_helper'

RSpec.describe UserIdentity, :type => :model do
  it { should belong_to(:user) }
  it { should have_one(:primary_user) }
  it { should belong_to(:email_pattern) }
  it { should belong_to(:organization) }
  it { should belong_to(:department) }

  it "sets the original_department automatically" do
    user_identity = build(:user_identity, :with_department)
    user_identity.original_department = nil
    user_identity.save!

    expect(user_identity.original_department).to eq user_identity.department

    od = user_identity.original_department
    d = create(:department, organization: od.organization)
    user_identity.department = d
    user_identity.save!

    expect(user_identity.original_department).to eq od
  end

  context "created after a matched confirmed UserEmail exists" do
    let!(:user) { create(:user) }
    let!(:email) { Faker::Internet.safe_email }
    let!(:user_email) { user.emails.create(email: email) }
    before do
      user_email.confirm!
    end

    it "links to the user automatically" do
      expect(user.organization).to be nil
      user_identity = create(:user_identity, :with_department, email: email)

      user.reload
      expect(user.organization).to eq user_identity.organization
    end
  end
end
