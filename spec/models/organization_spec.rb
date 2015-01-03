require 'rails_helper'

RSpec.describe Organization, :type => :model do
  it_should_behave_like "a codeable model"

  it { should have_many(:users) }
  it { should have_many(:departments) }
  it { should have_many(:email_patterns) }

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

  context "destroyed" do
    before do
      @org = create(:organization)
      @dep_1 = create(:department, organization: @org)
      @dep_2 = create(:department, organization: @org)
      @dep_1_1 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_2 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_3 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_1_1 = create(:department, organization: @org, parent: @dep_1_1)
      @org.destroy
    end

    it "deletes its departments while destroyed" do
      expect(Organization.exists?(@org)).to eq false
      expect(Department.exists?(@dep_1)).to eq false
      expect(Department.exists?(@dep_2)).to eq false
      expect(Department.exists?(@dep_1_1)).to eq false
      expect(Department.exists?(@dep_1_2)).to eq false
      expect(Department.exists?(@dep_1_3)).to eq false
      expect(Department.exists?(@dep_1_1_1)).to eq false
    end
  end
end
