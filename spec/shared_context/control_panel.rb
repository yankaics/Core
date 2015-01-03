RSpec.shared_context "create admin" do
  before :all do
    @admin = create(:admin)
  end
end

RSpec.shared_context "create scoped admin" do
  before :all do
    @admin = create(:admin, scoped_organization_code: 'ORG')
  end
end

RSpec.shared_context "create two organizations and four users" do
  before :all do
    @org = create(:organization, code: 'ORG')
    @gro = create(:organization, code: 'GRO')
    @usr = create(:user)
    @org_usr = create(:user, :in_organization, organization: @org)
    @gro_usr = create(:user, :in_organization, organization: @gro)
    @org_gro_usr = create(:user, :in_organization, organization: @org)
    create(:user_identity_link, :in_organization, user: @org_gro_usr, organization: @gro)
  end
end
