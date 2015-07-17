require 'rails_helper'

feature "SSO Status Iframe", :type => :feature do
  before :each do
    @user = create(:user)
    @user.confirm!
    page.driver.try(:block_unknown_urls)
    visit(sso_status_iframe_path)
    @sso_status_iframe_url = current_url
  end

  scenario "sso_status_iframe is iframed in a page", :js => true do
    document = <<-EOF.gsub(/\n/, '')
      <script type="text/javascript">
        function signOnStatusCallback(e) {
          if ("signOnStatus" in e.data) {
            signOnStatus = e.data.signOnStatus;
            document.write(JSON.stringify(signOnStatus));
          }
        }

        if ("addEventListener" in window) {
          window.addEventListener("message", signOnStatusCallback);
        } else if ("attachEvent" in window) {
          window.attachEvent("onmessage", signOnStatusCallback);
        }
      </script>

      <iframe src="#{@sso_status_iframe_url}"></iframe>
    EOF
    login_as @user
    visit('/')
    page.execute_script("document.body.innerHTML = ''\; document.write('#{document}')\;")
    expect(page).to have_content(@user.uuid)
  end
end
