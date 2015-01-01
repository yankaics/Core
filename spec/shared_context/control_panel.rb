RSpec.shared_context "login to admin panel" do
  before :each do
    @admin = create(:admin)
    login_as @admin, scope: :admin
  end
end
