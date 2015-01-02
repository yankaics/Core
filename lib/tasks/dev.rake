require "factory_girl"

namespace :dev do
  desc "Seed data for development environment"
  task prime: "db:setup" do

    if Rails.env.development?
      include FactoryGirl::Syntax::Methods

      ntust = create(:ntust_organization)
      nthu = create(:nthu_organization)

      create(:admin, username: 'ntust_admin', password: 'password', scoped_organization_code: 'NTUST')

      ntust.reload
      nthu.reload

      20.times { create(:user, :in_department, department: ntust.departments.sample, identity: UserIdentity::IDENTITES.keys.sample) }
      20.times { create(:user, :in_department, department: nthu.departments.sample, identity: UserIdentity::IDENTITES.keys.sample) }
    end
  end
end
