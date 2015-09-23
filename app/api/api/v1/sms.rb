class API::V1::SMS < API::V1
  rescue_from ActionController::ParameterMissing, Nexmo::Error do |e|
    error!({ error: 'sms_error', messages: e.to_s }, 400)
  end

  resources :sms, desc: "Send direct SMS" do
    desc "Send direct SMS", {
      http_codes: [
        [401, "Unauthorized: missing or bad app credentials."],
        [403, "Forbidden: your app is either blocked or has ran out of sms quota."]
      ],
      notes:  <<-NOTE
        This API is accessible only with app tokens, with apps that have remaining SMS quota.
      NOTE
    }
    params do
      requires :sms, type: Hash do
        requires :to, type: String, desc: "The SMS mobile number to send to."
        requires :text, type: String, desc: "The SMS message text."
      end
      optional :'sms[test]', desc: "Test request? (SMS will not actually send if set to true)"
    end
    post rabl: 'sms' do
      # Only applications with remaining SMS quota can use this API
      # (using their applications access token)
      if current_application.blank? ||
         current_application.sms_quota < 1 ||
         current_user.present?
        error!({ error: 403 }, 403)
      end

      @sms = {
        to: SMSService.mobile_number(params[:sms][:to]),
        text: params[:sms][:text],
        test: !!params[:sms][:test]
      }

      if !@sms[:test]
        current_application.sms_quota -= 1
        current_application.save!
        SMSService.send_message(to: @sms[:to], text: @sms[:text])

        status 201
      else
        status 200
      end
    end
  end
end
