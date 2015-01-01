require 'rails_helper'

RSpec.describe UserIdentity, :type => :model do
  it { should belong_to(:user) }
  it { should belong_to(:associated_user_email) }
  it { should have_one(:primary_user) }
  it { should belong_to(:email_pattern) }
  it { should belong_to(:organization) }
  it { should belong_to(:department) }

  it "sets the original_department automatically" do
    user_identity = build(:user_identity, :with_department)
    user_identity.original_department = nil
    user_identity.save!

    expect(user_identity.original_department).to eq user_identity.department
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

  describe "instantiation" do
    subject(:user_identity) { create :user_identity, :with_department }

    context "department changed while changing it isn't permitted" do
      before do
        department_2 = create(:department, organization: subject.organization)
        subject.department = department_2
      end
      it { is_expected.not_to be_valid }
    end

    context "department changed to a different group that isn't permitted" do
      before do
        subject.update(permit_changing_department_in_group: true)
        subject.department.update(group: 'M')
        department_2 = create(:department, organization: subject.organization, group: 'N')
        subject.department = department_2
      end
      it { is_expected.not_to be_valid }
    end

    context "department changed to a different group that is permitted" do
      before do
        subject.update(permit_changing_department_in_group: true)
        subject.department.update(group: 'M')
        department_2 = create(:department, organization: subject.organization, group: 'M')
        subject.department = department_2
      end
      it { is_expected.to be_valid }
    end

    context "department changed to a different group that is permitted" do
      before do
        subject.update(permit_changing_department_in_group: true)
        subject.department.update(group: 'M')
        department_2 = create(:department, group: 'M')
        subject.department = department_2
      end
      it { is_expected.not_to be_valid }
    end
  end
end
