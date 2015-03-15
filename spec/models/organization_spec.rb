require 'rails_helper'

RSpec.describe Organization, :type => :model do
  it_should_behave_like "a codeable model"

  it { should have_many(:users) }
  it { should have_many(:departments) }
  it { should have_many(:email_patterns) }
  it { should have_many(:data_apis) }

  it { should accept_nested_attributes_for(:departments) }
  it { should accept_nested_attributes_for(:email_patterns) }

  it { should validate_uniqueness_of(:code) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }

  it "validates associated departments" do
    org = create(:organization)
    org.departments.create(code: "安安 你好")
    expect(org).not_to be_valid
  end

  it "has friendly ID 'code'" do
    thing = build(described_class)
    thing.save!
    expect(described_class.friendly.find(thing.code)).to eq thing
  end

  describe ".all_for_select" do
    let!(:org_1) { create(:organization) }
    let!(:org_2) { create(:organization) }
    let!(:org_3) { create(:organization) }

    it "returns an array for all organization selections" do
      selections = Organization.all_for_select
      expect(selections).to include([org_1.name, org_1.code])
      expect(selections).to include([org_2.name, org_2.code])
      expect(selections).to include([org_3.name, org_3.code])
    end
  end

  describe ".short_name_list" do
    let!(:org_1) { create(:organization) }
    let!(:org_2) { create(:organization) }
    let!(:org_3) { create(:organization) }

    it "returns an array for all organization selections" do
      selections = Organization.short_name_list
      expect(selections).to include(org_1.short_name)
      expect(selections).to include(org_2.short_name)
      expect(selections).to include(org_3.short_name)
    end
  end

  context "destroyed" do
    before do
      @org = create(:organization)
      @dep_1 = create(:department, organization: @org)
      @dep_2 = create(:department, organization: @org)
      @dep_1_1 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_2 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_3 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_1_1 = create(:department, organization: @org, parent: @dep_1_1)
      @ep = create(:email_pattern, organization: @org)
      @ui = create(:user_identity, organization: @org)
      @org.destroy
    end

    it "deletes its departments while destroyed" do
      expect(Organization.exists?(@org)).to be false
      expect(Department.exists?(@dep_1)).to be false
      expect(Department.exists?(@dep_2)).to be false
      expect(Department.exists?(@dep_1_1)).to be false
      expect(Department.exists?(@dep_1_2)).to be false
      expect(Department.exists?(@dep_1_3)).to be false
      expect(Department.exists?(@dep_1_1_1)).to be false
    end

    it "deletes its email_patterns while destroyed" do
      expect(EmailPattern.exists?(@ep)).to be false
    end

    # it "deletes its user_identities while destroyed" do
    #   expect(UserIdentity.exists?(@ui)).to be false
    # end
  end
end
