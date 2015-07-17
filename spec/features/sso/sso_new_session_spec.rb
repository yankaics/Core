require 'rails_helper'

feature "SSO New Session", :type => :feature do
  before :each do
    @user = create(:user)
    @user.confirm!
    @core_app_access_token = create(:oauth_access_token, :core, resource_owner_id: @user.id, expires_in: 7200)
    @user_app_access_token = create(:oauth_access_token, resource_owner_id: @user.id, expires_in: 7200)
    page.driver.try(:block_unknown_urls)
    visit(sso_new_session_path)
    @sso_new_session_url = current_url
  end

  scenario "user login via sso_new_session" do
    # this functionality will not work for user apps
    visit("#{@sso_new_session_url}?access_token=#{@user_app_access_token.token}")
    visit(my_account_path)
    expect(page).not_to have_content(@user.name)
    # On background: sign-on status token (sst) cookie is expected to be blank
    sst_string = page.driver.request.cookies['_sst']
    expect(sst_string).to be_blank

    # this functionality will work for core apps
    visit("#{@sso_new_session_url}?access_token=#{@core_app_access_token.token}")
    visit(my_account_path)
    expect(page).to have_content(@user.name)
    # On background: sign-on status token (sst) cookie should be set
    sst_string = page.driver.request.cookies['_sst']
    sst = SignonStatusTokenService.decode(sst_string)
    expect(sst['id']).to eq(@user.id)
    expect(sst['uuid']).to eq(@user.uuid)

    # logout
    visit(destroy_user_session_path)
    sst_string = page.driver.request.cookies['_sst']
    expect(sst_string).to be_blank

    # this functionality will not work for expired access tokens
    Timecop.travel(1.year.from_now)
    visit("#{@sso_new_session_url}?access_token=#{@core_app_access_token.token}")
    visit(my_account_path)
    expect(page).not_to have_content(@user.name)
    # On background: sign-on status token (sst) cookie is expected to be blank
    sst_string = page.driver.request.cookies['_sst']
    expect(sst_string).to be_blank

    Timecop.return
  end
end
