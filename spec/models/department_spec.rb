require 'rails_helper'

RSpec.describe Department, :type => :model do
  it_should_behave_like "a codeable model"

  xit { should have_many(:users) }
  it { should have_many(:departments) }
  it { should belong_to(:parent) }

  it { should validate_presence_of(:organization) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }

  it "requires case sensitive in-organization unique code" do
    department_one = create(:department, code: '1337')
    department_two = build(:department, organization: department_one.organization, code: '1337')
    expect(department_two).not_to be_valid
  end

  describe ".root" do
    before do
      @org = create(:organization)
      @dep_1 = create(:department, organization: @org)
      @dep_2 = create(:department, organization: @org)
      @dep_1_1 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_2 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_3 = create(:department, organization: @org, parent: @dep_1)
      @dep_1_1_1 = create(:department, organization: @org, parent: @dep_1_1)
    end
    it "scopes the root departments" do
      expect(Department.root).to include(@dep_1)
      expect(Department.root).to include(@dep_2)
      expect(Department.root).not_to include(@dep_1_1)
      expect(Department.root).not_to include(@dep_1_2)
      expect(Department.root).not_to include(@dep_1_3)
      expect(Department.root).not_to include(@dep_1_1_1)
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
      @dep_1.destroy
    end

    it "destroys its departments while destroyed" do
      expect(Organization.exists?(@org)).to eq true
      expect(Department.exists?(@dep_2)).to eq true
      expect(Department.exists?(@dep_1)).to eq false
      expect(Department.exists?(@dep_1_1)).to eq false
      expect(Department.exists?(@dep_1_2)).to eq false
      expect(Department.exists?(@dep_1_3)).to eq false
      expect(Department.exists?(@dep_1_1_1)).to eq false
    end
  end
end
