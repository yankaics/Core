require "factory_girl"

namespace :dev do
  desc "Seed data for development environment"
  task prime: "db:setup" do

    if Rails.env.development?
      include FactoryGirl::Syntax::Methods

      create(:ntust_organization)
      create(:nthu_organization)
    end
  end
end
