OmniAuth.config.mock_auth[:facebook] = {
  provider: 'facebook',
  uid: '87654321',
  info: {
    email: 'mock_user@facebook.com',
    name: 'Facebook User',
    first_name: 'Facebook',
    last_name: 'User',
    urls: {
      :'Facebook' => 'https://www.facebook.com/app_scoped_user_id/87654321/'
    },
    verified: true
  },
  credentials: {
    token: 'mock_token'
  },
  extra: {
    raw_info: {
      gender: 'male',
      locale: 'zh_TW',
      timezone: 8
    }
  }
}
