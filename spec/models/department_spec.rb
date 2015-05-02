require 'rails_helper'

RSpec.describe Department, :type => :model do
  it_should_behave_like "a codeable model"

  it { should have_many(:users) }
  it { should have_many(:departments) }
  it { should belong_to(:parent) }

  it { should validate_presence_of(:organization) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }

  it "requires case sensitive unique code in organization" do
    department_one = create(:department, code: '1337')
    department_two = build(:department, organization: department_one.organization, code: '1337')
    expect(department_two).not_to be_valid
  end

  before do
    @org = create(:organization)
    @dep_1 = create(:department, organization: @org)
    @dep_2 = create(:department, organization: @org)
    @dep_1_1 = create(:department, organization: @org, parent: @dep_1)
    @dep_1_2 = create(:department, organization: @org, parent: @dep_1)
    @dep_1_3 = create(:department, organization: @org, parent: @dep_1)
    @dep_1_1_1 = create(:department, organization: @org, parent: @dep_1_1)
    @org_2 = create(:organization)
    @org_2_dep_1 = create(:department, organization: @org_2, code: @dep_1.code)
    @org_2_dep_1_1 = create(:department, organization: @org_2, parent: @org_2_dep_1, code: @dep_1_1.code)
    @org_2_dep_1_2 = create(:department, organization: @org_2, parent: @org_2_dep_1, code: @dep_1_2.code)
    @org_2_dep_1_3 = create(:department, organization: @org_2, parent: @org_2_dep_1, code: @dep_1_3.code)
    @org_2_dep_1_1_1 = create(:department, organization: @org_2, parent: @org_2_dep_1_1, code: @dep_1_1_1.code)
  end

  it "should belong to parent with matching parent_code in the same organization" do
    expect(@dep_1_1.parent).to eq @dep_1
    expect(@dep_1_1_1.parent).to eq @dep_1_1
    expect(@org_2_dep_1_1_1.parent).to eq @org_2_dep_1_1
  end

  it "should have many departments with matching parent_code in the same organization" do
    expect(@dep_1.departments).to contain_exactly(@dep_1_1, @dep_1_2, @dep_1_3)
    expect(@org_2_dep_1.departments).to contain_exactly(@org_2_dep_1_1, @org_2_dep_1_2, @org_2_dep_1_3)
  end

  describe ".root" do
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
      @dep_1.destroy
    end

    it "destroys its departments while destroyed" do
      expect(Organization.exists?(@org.id)).to eq true
      expect(Department.exists?(@dep_2.id)).to eq true
      expect(Department.exists?(@dep_1.id)).to eq false
      expect(Department.exists?(@dep_1_1.id)).to eq false
      expect(Department.exists?(@dep_1_2.id)).to eq false
      expect(Department.exists?(@dep_1_3.id)).to eq false
      expect(Department.exists?(@dep_1_1_1.id)).to eq false
    end
  end
end
