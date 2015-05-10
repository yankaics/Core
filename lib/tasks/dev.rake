require "factory_girl"

namespace :dev do
  desc "Seed data for development environment"
  task prime: "db:setup" do

    if Rails.env.development? || ENV['STAGING'].present?
      include FactoryGirl::Syntax::Methods

      ntust = create(:ntust_organization)
      nthu = create(:nthu_organization)

      create(:admin, username: 'ntust_admin', password: 'password', scoped_organization_code: 'NTUST')

      ntust.reload
      nthu.reload

      12.times do
        u = create(:user, :in_department, department: ntust.departments.sample, identity: UserIdentity::IDENTITIES.keys.sample)
        u.confirm!
      end
      12.times do
        u = create(:user, :in_department, department: nthu.departments.sample, identity: UserIdentity::IDENTITIES.keys.sample)
        u.confirm!
      end

      create(:data_api, name: 'nice_store', table_name: 'nice_stores', path: 'test/nice_stores', schema: { code: { type: 'string', null: false, unique: true, primary_key: true }, name: { type: 'string', null: false }, location_latitude: { type: 'string' }, location_longitude: { type: 'string' }, open_at: { type: 'integer' }, close_at: { type: 'integer' }, description: { type: 'text' } })
    end
  end
end
