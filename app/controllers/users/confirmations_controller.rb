class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |user|
      # sign in and redirect to new_my_account_email_path,
      # only for new users (.unconfirmed_email.blank?)
      # without identity (.primary_identity_id.blank?)
      if !Settings.skip_new_user_identity_verification &&
         user && user.created_at &&
         user.primary_identity_id.blank? &&
         user.unconfirmed_email.blank?
        sign_in user
        SignonStatusTokenService.write_to_cookie(cookies, user)
        redirect_to new_my_account_email_path and return
      end
    end
  end
end
