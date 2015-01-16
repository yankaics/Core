require 'rails_helper'

feature "User Verificate", :type => :feature, focus: true do
  before :all do
    @ntust = create(:ntust_organization)
    @nthu = create(:nthu_organization)
    @user_a1 = create(:user)
    @user_a2 = create(:user)
    @user_b1 = create(:user)
    @user_b2 = create(:user)
    @user_a1.confirm!
    @user_a2.confirm!
    @user_b1.confirm!
    @user_b2.confirm!
  end

  scenario "User verifies an email", :js => true do
    login_as @user_a1
    visit(new_my_account_email_path)
    fill_in('user_email_email', with: 'b10132023@mail.ntust.edu.tw')
    expect(page).to have_content('國立臺灣科技大學')
    # ...
  end
end
