class API::V1::Utilities < API::V1
  # rescue_from :all

  group :utilities, desc: "Utilities and tools" do
    desc "Get info of the current access token"
    get "access_token" do
      guard!

      resource_owner_info = nil
      if current_access_token.resource_owner.present?
        resource_owner_info = {
          id: current_access_token.resource_owner_id,
          uuid: current_access_token.resource_owner.uuid,
          username: current_access_token.resource_owner.username,
          name: current_access_token.resource_owner.name
        }
      end

      {
        application: {
          uid: current_access_token.application.uid,
          name: current_access_token.application.name
        },
        resource_owner_id: current_access_token.resource_owner_id,
        resource_owner: resource_owner_info,
        scopes: current_access_token.scopes,
        expires_in: current_access_token.expires_in,
        expires_in_seconds: current_access_token.expires_in_seconds,
        created_at: current_access_token.created_at.to_i,
        refresh_token: current_access_token.refresh_token.present?
      }
    end

    desc "Send named notifications"
    params do
      optional :organization_code, type: String
      optional :course_code, type: String
    end
    get "snn" do
      guard!

      MobileNotificationService.send_named_notification(params[:organization_code], params[:course_code])

      nil
    end

    desc "Simulate errors"
    params do
      optional :code, type: Integer, default: 418, desc: "HTTP error code."
      optional :name, type: String, desc: "Error name."
      optional :description, type: String, desc: "Error description."
    end
    get "error" do
      error = {}

      error[:error] = params[:name] || params[:code]
      error[:error_description] = params[:description] if params[:description].present?

      error!(error, params[:code])
    end
  end
end
