require 'rails_helper'

feature "SSO Redirect Iframe", :type => :feature do
  before :each do
    @user = create(:user)
    @user.confirm!
    page.driver.block_unknown_urls
    visit(sso_redirect_iframe_path)
    @sso_redirect_iframe_url = current_url
  end

  scenario "users will be redirected to the sign in url if needed", :js => true do
    login_as @user
    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=false&sign_in_url=http://example.com/sign-in" width="0" height="0"></iframe>\');')
    expect(current_url).to eq('http://example.com/sign-in')

    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=true&sign_in_url=http://example.com/sign-in" width="0" height="0"></iframe>\');')
    expect(URI.parse(current_url).path).to eq('/')
  end

  scenario "users will be redirected to the sign out url if needed", :js => true do
    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=true&sign_out_url=http://example.com/sign-out" width="0" height="0"></iframe>\');')
    expect(current_url).to eq('http://example.com/sign-out')

    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=false&sign_out_url=http://example.com/sign-out" width="0" height="0"></iframe>\');')
    expect(URI.parse(current_url).path).to eq('/')

    login_as @user
    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=true&sign_out_url=http://example.com/sign-out" width="0" height="0"></iframe>\');')
    expect(URI.parse(current_url).path).to eq('/')
  end

  scenario "users will be redirected to the update user url if needed", :js => true do
    login_as @user
    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=true&user_updated_at=' + (@user.updated_at.to_i - 1).to_s + '&update_user_url=http://example.com/update-user" width="0" height="0"></iframe>\');')
    expect(current_url).to eq('http://example.com/update-user')

    visit('/')
    page.execute_script('document.write(\'<iframe src="' + @sso_redirect_iframe_url + '?s=true&user_updated_at=' + (@user.updated_at.to_i + 1).to_s + '&update_user_url=http://example.com/update-user" width="0" height="0"></iframe>\');')
    expect(URI.parse(current_url).path).to eq('/')
  end
end
