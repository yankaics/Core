require 'rails_helper'
require 'validates_email_format_of/rspec_matcher'

RSpec.describe UserEmail, :type => :model do
  let(:user) { create(:user) }
  let(:user_email) { user.emails.create(email: Faker::Internet.safe_email) }

  it { should belong_to(:user) }
  it { should have_one(:associated_user_identity) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:email) }
  # it { should validate_uniqueness_of(:confirmation_token).allow_nil }

  it "validates email format" do
    user_email.email = 'the_quick_brown-fox*jumps^over-the_lazy_dog'
    expect(user_email).not_to be_valid
    expect(user).not_to be_valid
  end

  context "when builded" do
    it "strips the email" do
      e = user.emails.build(email: ' foo@bar.baz ')
      expect(e.email).to eq('foo@bar.baz')
    end
  end

  context "when created" do
    subject { user_email }
    it { is_expected.not_to be_confirmed }
    its(:confirmation_token) { is_expected.not_to be_blank }
    it "strips the email" do
      e = user.emails.create(email: ' foo@bar.baz ')
      expect(e.email).to eq('foo@bar.baz')
    end
  end

  context "when the user has a same email" do
    before do
      @email = Faker::Internet.safe_email
      user.emails.create(email: @email)
    end
    subject { user.emails.create(email: @email) }

    it { is_expected.not_to be_valid }
  end

  context "when a same and confirmed email exists" do
    before do
      @email = Faker::Internet.safe_email
      create(:user).emails.create(email: @email).confirm!
    end
    subject { user.emails.create(email: @email) }

    it { is_expected.not_to be_valid }

    it "can't be confirmed" do
      expect { subject.confirm! }.to raise_error
      expect(subject.confirm).to be false
      expect(subject.confirmed?).to be false
    end
  end

  context "when a same and unconfirmed email exists" do
    before do
      @email = Faker::Internet.safe_email
      create(:user).emails.create(email: @email)
    end
    subject { user.emails.create(email: @email) }

    it { is_expected.to be_valid }

    it "can be confirmed" do
      expect(subject.confirm).not_to be false
      expect(subject.confirmed?).to be true
    end
  end

  context "when confirmed" do
    subject { user_email.confirm! }
    it { is_expected.to be_confirmed }
    its(:confirmation_token) { is_expected.to be_blank }

    context "having matched EmailPattern" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_email) { user.emails.create(email: 'B10132023@mail.ntust.edu.tw') }

      it "creates UserIdentity for the user" do
        expect(user.organization).to eq nil
        user_email.confirm
        user.reload
        expect(user.organization).to eq ntust
      end

      it "creates UserIdentity for the user and sets the department via option" do
        user_email.department_code = 'D10'
        user_email.save!
        expect(user.organization).to eq nil
        user_email.confirm
        user.reload
        expect(user.organization).to eq ntust
        expect(user.department_code).to eq 'D10'
      end
    end

    context "having matched predefined UserIdentity" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_identity) { create(:user_identity, organization: ntust, email: 'me@ntust.edu.tw') }
      let!(:user_email) { user.emails.create(email: 'me@ntust.edu.tw') }

      it "links the UserIdentity to the user" do
        expect(user.organization).to eq nil
        user_email.confirm
        user.reload
        expect(user.organization).to eq ntust
      end

      it "links the UserIdentity to the user and sets the department via option" do
        user_identity.permit_changing_department_in_organization = true
        user_identity.save!
        user_email.department_code = 'D10'
        user_email.save!
        expect(user.organization).to eq nil
        user_email.confirm
        user.reload
        expect(user.organization).to eq ntust
        expect(user.department_code).to eq 'D10'
      end
    end
  end

  context "when destroyed" do
    context "with corresponding generated UserIdentity" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_email) { user.emails.create(email: 'B10132023@mail.ntust.edu.tw') }
      before do
        user_email.confirm!
      end

      it "destroys the UserIdentity for the user" do
        user_identity = user.identities.first
        user_email.destroy
        user.reload
        expect(user.identities.count).to eq(0)
        expect(UserIdentity.exists?(user_identity.id)).to be false
      end
    end

    context "with corresponding predefined UserIdentity" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_identity) { create(:user_identity, organization: ntust, email: 'me@ntust.edu.tw') }
      let!(:user_email) { user.emails.create(email: 'me@ntust.edu.tw') }
      before do
        user_email.confirm!
      end

      it "unlinks the UserIdentity with the user" do
        user_identity = user.identities.first
        user_email.destroy
        user.reload
        expect(user.identities.count).to eq(0)
        expect(UserIdentity.exists?(user_identity.id)).to be true
        user_identity.reload
        expect(user_identity.user_id).to be nil
      end
    end
  end

  describe "#re_identify!" do
    context "with an unidentified email" do
      let(:email) { e = create(:user_email, email: 'b10132023@mail.ntust.edu.tw'); e.confirm!; e }
      let(:user) { email.user }
      before do
        expect(user.organization_code).to be_nil
      end

      it "re-identifies itself" do
        create(:ntust_organization)

        email.re_identify!
        user.reload
        expect(user.organization_code).to eq('NTUST')
      end
    end

    context "with an old generated identity" do
      before do
        # suppose we don't have an detailed Email Pattern for students of NTUST in the past
        create(:ntust_organization)
        EmailPattern.where(corresponded_identity: UserIdentity::IDENTITIES[:student]).destroy_all
        expect(user.organization_code).to eq('NTUST')
        expect(user.identity).to eq('staff')
      end

      let(:email) { e = create(:user_email, email: 'b10132023@mail.ntust.edu.tw'); e.confirm!; e }
      let(:user) { email.user }

      it "re-identifies itself" do
        # we don't have an Email Pattern for students of NTUST before, but now we did
        email.reload
        expect(email.linked_associated_user_identity.identity).to eq('staff')
        create(:ntust_student_email_pattern)

        email.re_identify!
        user.reload
        expect(user.organization_code).to eq('NTUST')
        expect(user.identity).to eq('student')
        expect(user.primary_identity.original_department_code).to eq('D32')
      end

      it "keeps the old user changable attributes" do
        # user changes their department code
        identity = user.primary_identity
        identity.department_code = 'U01'
        identity.save!

        # we don't have an Email Pattern for students of NTUST before, but now we did
        email.reload
        expect(email.linked_associated_user_identity.identity).to eq('staff')
        create(:ntust_student_email_pattern)

        email.re_identify!
        user.reload
        expect(user.organization_code).to eq('NTUST')
        expect(user.identity).to eq('student')

        # the old department_code remains even if its invalid
        expect(user.department_code).to eq('U01')
        # the user_identity becomes invalid because it's original_department has changed to a different group
        expect(user.primary_identity.save).to eq(false)
      end
    end

    context "with an out-dated generated identity" do
      before do
        # suppose we only have a simple email pattern in the past
        ntust = create(:ntust_organization)
        EmailPattern.destroy_all
        create(:email_pattern, priority: 30, organization: ntust, corresponded_identity: UserIdentity::IDENTITIES[:student], email_regexp: '^(?<uid>.+)@mail\\.ntust\\.edu\\.tw$', uid_postparser: "n.toLowerCase()", permit_changing_department_in_organization: true)
        expect(student_user.organization_code).to eq('NTUST')
        expect(student_user.identity).to eq('student')
        expect(staff_user.organization_code).to eq('NTUST')
        expect(staff_user.identity).to eq('student')
      end

      let(:student_email) { e = create(:user_email, email: 'b10132023@mail.ntust.edu.tw'); e.confirm!; e }
      let(:student_user) { student_email.user }
      let(:staff_email) { e = create(:user_email, email: 'staff@mail.ntust.edu.tw'); e.confirm!; e }
      let(:staff_user) { staff_email.user }

      it "re-identifies itself" do
        # we only have a simple email pattern in before, but now we have detailed ones
        EmailPattern.destroy_all
        create(:ntust_student_email_pattern)
        create(:ntust_staff_email_pattern)

        student_email.re_identify!
        student_user.reload
        expect(student_user.organization_code).to eq('NTUST')
        expect(student_user.identity).to eq('student')
        expect(student_user.primary_identity.original_department_code).to eq('D32')

        staff_email.re_identify!
        staff_user.reload
        expect(staff_user.organization_code).to eq('NTUST')
        expect(staff_user.identity).to eq('staff')
      end
    end

    context "the pattern doesn't change" do
      before do
        create(:ntust_organization)
      end

      let(:email) { e = create(:user_email, email: 'b10132023@mail.ntust.edu.tw'); e.confirm!; e }
      let(:user) { email.user }

      it "does nothing" do
        prev_identity_id = user.primary_identity.id

        email.re_identify!
        user.reload
        after_identity_id = user.primary_identity.id

        expect(after_identity_id).to eq(prev_identity_id)
      end

      it "does nothing even if the identity's changable attributes has changed" do
        prev_identity = user.primary_identity
        prev_identity.department_code = 'D10'
        prev_identity.save!
        prev_identity_id = prev_identity.id

        email.reload
        email.re_identify!
        user.reload
        after_identity_id = user.primary_identity.id

        expect(after_identity_id).to eq(prev_identity_id)
      end
    end

    context "the associated user_identity is predefined" do
      before do
        create(:ntust_organization)
        create(:user_identity, email: 'b10132023@mail.ntust.edu.tw', identity: 'staff')
        expect(user.identity).to eq('staff')
      end

      let(:email) { e = create(:user_email, email: 'b10132023@mail.ntust.edu.tw'); e.confirm!; e }
      let(:user) { email.user }

      it "does nothing" do
        prev_identity_id = user.primary_identity.id

        email.re_identify!
        user.reload
        after_identity_id = user.primary_identity.id

        expect(after_identity_id).to eq(prev_identity_id)
      end
    end

    context "there is a newly created predefined user_identity while the original one is generated" do
      # this test is associated with UserIdentity spec context "created after a matched confirmed UserEmail exists", it "destroys the generated user user_identity with the same email automatically"
      before do
        create(:ntust_organization)
      end

      let(:email) { e = create(:user_email, email: 'b10132023@mail.ntust.edu.tw'); e.confirm!; e }
      let(:user) { email.user }

      it "links the new user_identity and destroy the old one" do
        expect(user.identity).to eq('student')
        prev_identity_id = user.primary_identity.id

        create(:user_identity, email: 'b10132023@mail.ntust.edu.tw', identity: 'staff')
        email.re_identify!

        user.reload
        expect(user.identity).to eq('staff')
        expect(UserIdentity.find_by(id: prev_identity_id)).to be nil
      end
    end
  end
end
