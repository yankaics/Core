require 'rails_helper'

feature "EULA", :type => :feature do
  before do
    @eula = Faker::Lorem.paragraph
    Settings[:site_eula] = @eula
  end

  scenario "Visiter reads EULA" do
    visit(eula_path)
    expect(page).to have_content(@eula)
  end
end
