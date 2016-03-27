class API::V1::RollCallNotificationAPI < API::V1
  rescue_from ActionController::ParameterMissing do |e|
    error!({ error: e.to_s }, 400)
  end

  guard_all!

  resource :roll_call_notification, desc: "點名通知" do
    desc "查詢點名通知目前狀態", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note}
      NOTE
    }
    params do
      requires :organization_code, desc: '學校代碼'
      requires :course_code, desc: '課程代碼'
    end
    get do
      rcn = RollCallNotification.find_by(organization_code: params[:organization_code], course_code: params[:course_code])
      is_available = true

      if rcn && rcn.created_at < 20.minutes.ago
        is_available = false
      end

      {
        user_id: rcn && rcn.user_id,
        organization_code: rcn && rcn.organization_code,
        course_code: rcn && rcn.course_code,
        created_at: rcn && rcn.created_at,
        is_available: is_available
      }
    end

    desc "送出點名通知", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note}
      NOTE
    }
    params do
      requires :organization_code, desc: '學校代碼'
      requires :course_code, desc: '課程代碼'
    end
    post do
      old_rcn = RollCallNotification.find_by(organization_code: params[:organization_code], course_code: params[:course_code])

      if old_rcn && (Time.now - old_rcn.created_at) < 20.minutes
        status 400
        {
          user_id: old_rcn && old_rcn.user_id,
          organization_code: old_rcn && old_rcn.organization_code,
          course_code: old_rcn && old_rcn.course_code,
          created_at: old_rcn && old_rcn.created_at
        }
      else
        rcn = RollCallNotification.create!(organization_code: params[:organization_code], course_code: params[:course_code], user_id: current_user.id)
        MobileNotificationService.send_roll_call_notification(params[:organization_code], params[:course_code])
        status 201
        {
          user_id: rcn.user_id,
          organization_code: rcn.organization_code,
          course_code: rcn.course_code,
          created_at: rcn.created_at,
          is_available: false
        }
      end
    end
  end
end
