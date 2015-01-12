require 'rails_helper'

feature "User Auth", :type => :feature do
  before do
    stub_request(:get, "https://graph.facebook.com/me?access_token=mock_token&fields=id,name,link,picture.height(500).width(500),cover,devices,friends&locale=zh-TW")
      .to_return(:status => 200, :body => (<<-eod
{
   "id": "87654321",
   "name": "Facebook User",
   "link": "https://www.facebook.com/app_scoped_user_id/87654321/",
   "picture": {
      "data": {
         "height": 720,
         "is_silhouette": false,
         "url": "http://placehold.it/500x500",
         "width": 720
      }
   },
   "cover": {
      "id": "87654321",
      "offset_y": 55,
      "source": "http://placehold.it/1280x600"
   },
   "devices": [
      {
         "os": "Android"
      },
      {
         "hardware": "iPad",
         "os": "iOS"
      }
   ],
   "friends": {
      "data": [
         {
            "name": "Facebook User2",
            "id": "12345678"
         },
         {
            "name": "Facebook User3",
            "id": "87655678"
         }
      ],
      "paging": {
         "next": "https://graph.facebook.com/friends_get_next_page"
      },
      "summary": {
         "total_count": 52
      }
   }
}
eod
      ), :headers => {})
    stub_request(:get, "https://graph.facebook.com/friends_get_next_page")
      .to_return(:status => 200, :body => (<<-eod
{
   "data": [
     {
        "name": "Facebook User4",
        "id": "12344321"
     },
     {
        "name": "Facebook User5",
        "id": "23455432"
     }
   ],
   "paging": {
      "previous": ""
   },
   "summary": {
      "total_count": 52
   }
}
eod
      ), :headers => {})
  end

  scenario "new User signs in with Facebook" do
    visit(new_user_session_path)
    click_on('Sign in with Facebook', match: :first)
    # expect(page).to ...
  end

  scenario "returning User signs in with Facebook" do
    user = create(:user)
    user.update(fbid: '87654321')
    visit(new_user_session_path)
    click_on('Sign in with Facebook', match: :first)
    # expect(page).to ...
  end
end
