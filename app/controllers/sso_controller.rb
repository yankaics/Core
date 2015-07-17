class SSOController < ApplicationController
  include RedirectCheckingHelper

  # Refresh the sign-on status token (sst) in cookie
  def refresh_sst
    refresh_signon_status_token

    check_redirect_to

    if can_redirect
      redirect_to redirect_url
    else
      redirect_to root_path
    end
  end

  # GET the SST
  def get_sst
    render text: SignonStatusTokenService.generate(current_user)
  end

  # GET the sign on status
  def get_sso_status
    @user = current_user
    @data = {
      id: @user.id,
      uuid: @user.uuid,
      updated_at: @user.updated_at.to_i
    } if @user.present?

    headers['Access-Control-Allow-Origin'] = '*'
    headers['X-Frame-Options'] = 'ALLOWALL'

    respond_to do |format|
      format.json do
        render json: @data
      end

      format.html do
        render text: <<-EOF
<script type="text/javascript">
  window.parent.postMessage({ signOnStatus: #{@data.to_json} }, '*');
</script>
        EOF
      end
    end
  end

  # an iframe to redirect its parent base on the current sign in status
  def get_sso_redirect_iframe
    headers['Access-Control-Allow-Origin'] = '*'
    headers['X-Frame-Options'] = 'ALLOWALL'

    if current_user
      if params[:s] == 'false' && params[:sign_in_url]
        render text: <<-EOF
<script type="text/javascript">
  if (window.self != window.parent) window.parent.location.href = "#{params[:sign_in_url]}";
</script>
        EOF
      elsif params[:s] == 'true' && params[:user_updated_at] && params[:update_user_url] &&
            params[:user_updated_at].to_i < current_user.updated_at.to_i
        render text: <<-EOF
<script type="text/javascript">
  if (window.self != window.parent) window.parent.location.href = "#{params[:update_user_url]}";
</script>
        EOF
      end
    else
      if params[:s] == 'true' && params[:sign_out_url]
        render text: <<-EOF
<script type="text/javascript">
  if (window.self != window.parent) window.parent.location.href = "#{params[:sign_out_url]}";
</script>
        EOF
      end
    end

    render nothing: true unless performed?
  end

  def get_sso_new_session
    if params[:access_token].present?
      headers['Access-Control-Allow-Origin'] = '*'
      headers['X-Frame-Options'] = 'ALLOWALL'
      render nothing: true and return if params[:access_token] == '_'

      @access_token = Doorkeeper::AccessToken.by_token(params[:access_token])
      if @access_token &&
         OAuth::AccessTokenValidationService.validate(@access_token) == :valid &&
         @access_token.application && @access_token.application.core_app?
        @user = User.find_by(id: @access_token.resource_owner_id)

        if @user
          sign_in @user
          SignonStatusTokenService.write_to_cookie(cookies, @user)
        end
      end

      redirect_to sso_new_session_path and return
    end

    render nothing: true unless performed?
  end

  # GET the RSA public key
  def get_rsa_public_key
    render text: CoreRSAKeyService.public_key_string
  end
end
