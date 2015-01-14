require 'rails_helper'

RSpec.describe EmailPattern, :type => :model do
  it { should belong_to(:organization) }
  it { should validate_presence_of :organization }
  it { should validate_presence_of :priority }
  it { should validate_presence_of :corresponded_identity }
  it { should validate_presence_of :email_regexp }

  it "requires email_regexp to be valid regular expression" do
    email_pattern = build(:email_pattern, email_regexp: '?><')
    expect(email_pattern).to be_invalid
    email_pattern = build(:email_pattern, email_regexp: '^abc$')
    expect(email_pattern).to be_valid
  end

  it "requires post parsers to be valid JavaScript" do
    email_pattern = build(:email_pattern, uid_postparser: '><"')
    expect(email_pattern).to be_invalid
    email_pattern = build(:email_pattern, department_code_postparser: 'n + n')
    expect(email_pattern).to be_valid
    email_pattern = build(:email_pattern, department_code_postparser: '(つд⊂)')
    expect(email_pattern).to be_invalid
    email_pattern = build(:email_pattern, identity_detail_postparser: 'n.slice(1,2)')
    expect(email_pattern).to be_valid
    email_pattern = build(:email_pattern, identity_detail_postparser: 'ᶘ ᵒᴥᵒᶅ')
    expect(email_pattern).to be_invalid
    email_pattern = build(:email_pattern, started_at_postparser: '"Apple".match(n)')
    expect(email_pattern).to be_valid
  end

  describe ".identify" do
    it "identifies an email" do
      create(:ntust_organization)
      create(:nthu_organization)

      identity_data = EmailPattern.identify('b10132023@mail.ntust.edu.tw')
      expect(identity_data).to be_a_kind_of(Hash)
      expect(identity_data[:email]).to eq('b10132023@mail.ntust.edu.tw')
      expect(identity_data[:organization_code]).to eq('NTUST')
      expect(identity_data[:department_code]).to eq('D32')
      expect(identity_data[:identity]).to eq('student')
      expect(identity_data[:identity_detail]).to eq('bachelor')
      expect(identity_data[:uid]).to eq('b10132023')
      expect(identity_data[:started_at].year).to eq(2012)
      expect(identity_data[:email_pattern_id]).not_to be_nil
      expect(identity_data[:permit_changing_department_in_group]).to be true
      expect(identity_data[:permit_changing_department_in_organization]).to be false

      identity_data = EmailPattern.identify('b9832018@mail.ntust.edu.tw')
      expect(identity_data).to be_a_kind_of(Hash)
      expect(identity_data[:email]).to eq('b9832018@mail.ntust.edu.tw')
      expect(identity_data[:organization_code]).to eq('NTUST')
      expect(identity_data[:department_code]).to eq('D32')
      expect(identity_data[:identity]).to eq('student')
      expect(identity_data[:identity_detail]).to eq('bachelor')
      expect(identity_data[:uid]).to eq('b9832018')
      expect(identity_data[:started_at].year).to eq(2009)
      expect(identity_data[:email_pattern_id]).not_to be_nil

      identity_data = EmailPattern.identify('AbC.De-#@mail.ntust.edu.tw')
      expect(identity_data).to be_a_kind_of(Hash)
      expect(identity_data[:email]).to eq('AbC.De-#@mail.ntust.edu.tw')
      expect(identity_data[:organization_code]).to eq('NTUST')
      expect(identity_data[:identity]).to eq('staff')
      expect(identity_data[:uid]).to eq('abc.de-')
      expect(identity_data[:email_pattern_id]).not_to be_nil

      identity_data = EmailPattern.identify('s100022110@m100.nthu.edu.tw')
      expect(identity_data).to be_a_kind_of(Hash)
      expect(identity_data[:email]).to eq('s100022110@m100.nthu.edu.tw')
      expect(identity_data[:organization_code]).to eq('NTHU')
      expect(identity_data[:department_code]).to eq('0221')
      expect(identity_data[:identity]).to eq('student')
      expect(identity_data[:identity_detail]).to eq('bachelor')
      expect(identity_data[:uid]).to eq('100022110')
      expect(identity_data[:started_at].year).to eq(2011)
      expect(identity_data[:email_pattern_id]).not_to be_nil
    end
  end
end
