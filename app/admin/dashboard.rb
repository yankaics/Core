ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    columns do
      column do
        panel "System Info" do
          div Rails::Info.to_s.gsub(/\n/, '<br>').html_safe
          hr
          if Settings['admin_dashboard_l1_chart_code'].to_s != ''
            div Settings['admin_dashboard_l1_chart_code'].html_safe
            hr
          end
          ul do
            ENV.each do |key, value|
              if key =~ /key$/ || key =~ /secret/ || key =~ /pepper$/ ||
                 key =~ /KEY$/ || key =~ /SECRET/ || key =~ /PEPPER$/ || key =~ /DATABASE/
                li "#{key}: #{value[0..7] + value.gsub(/..?.?/, '*')}"
              else
                value = value[0..50] + '...' if value.length > 50
                li "#{key}: #{value}"
              end
            end
          end if current_admin.root?
        end
        (2..8).each do |i|
          if Settings["admin_dashboard_l#{i}_chart_code"].to_s != ''
            panel "<a target=\"_blank\" href=\"#{Settings["admin_dashboard_l#{i}_chart_title_url"]}\">#{Settings["admin_dashboard_l#{i}_chart_title"]}</a>".html_safe do
              div Settings["admin_dashboard_l#{i}_chart_code"].html_safe
            end
          end
        end
      end
      column do
        if Settings['admin_dashboard_r1_chart_code'].to_s != ''
          panel "<a target=\"_blank\" href=\"#{Settings['admin_dashboard_r1_chart_title_url']}\">#{Settings['admin_dashboard_r1_chart_title']}</a>".html_safe do
            div Settings['admin_dashboard_r1_chart_code'].html_safe
          end
        end
        panel '<a href="/admin/users?q%5Bcurrent_sign_in_at_gteq%5D=1994-07-02&order=current_sign_in_at_desc&as=detailed_table">Recent Signed-In Users</a>'.html_safe do
          table_for User.scoped(current_admin.scoped_organization_code).includes(:primary_identity).where('current_sign_in_at IS NOT NULL').order("current_sign_in_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(truncate(user.fbid, length: 8), "https://facebook.com/#{user.fbid}", :target => "_blank") if user.fbid }
            column("UID") { |user| truncate(user.uid, length: 12) }
            column("Sign In Time") { |user| user.current_sign_in_at && distance_of_time_in_words_to_now(user.current_sign_in_at) }
            column("Sign In Count") { |user| "#{user.sign_in_count} (#{'%.3f' % (user.sign_in_count.to_f / ((Time.now - user.created_at) / 1.day)+0.5)}/day)" }
            column("IP") { |user| (user.current_sign_in_ip == user.last_sign_in_ip) ? status_tag(user.current_sign_in_ip, :class => 'yes') : status_tag(user.current_sign_in_ip) }
            column("Last Sign In Ip") { |user| user.last_sign_in_ip }
          end
        end
        panel '<a href="/admin/users?order=created_at_desc&as=detailed_table">Recent Registered Users</a>'.html_safe do
          table_for User.scoped(current_admin.scoped_organization_code).includes(:primary_identity, :organizations).order("created_at DESC").limit(10) do
            column("Name") { |user| link_to(user.name, admin_user_path(user)) }
            column("Fbid") { |user| link_to(truncate(user.fbid, length: 16), "https://facebook.com/#{user.fbid}", :target => "_blank") if user.fbid }
            column("Org") { |user| truncate(user.organization_short_name, length: 5) }
            column("UID") { |user| truncate(user.uid, length: 12) }
            column("Created At") { |user| user.created_at.to_s.gsub(/\+\d{2}00/, '') }
            column("C/V?") do |user|
              if user.confirmed?
                status_tag('Yes', :class => 'yes')
              else
                status_tag('No', :class => 'no')
              end
              if user.verified?
                status_tag('Yes', :class => 'yes')
              else
                status_tag('No', :class => 'no')
              end
            end
            column("IP") { |user| user.current_sign_in_ip }
          end
        end
        (2..8).each do |i|
          if Settings["admin_dashboard_r#{i}_chart_code"].to_s != ''
            panel "<a target=\"_blank\" href=\"#{Settings["admin_dashboard_r#{i}_chart_title_url"]}\">#{Settings["admin_dashboard_r#{i}_chart_title"]}</a>".html_safe do
              div Settings["admin_dashboard_r#{i}_chart_code"].html_safe
            end
          end
        end
      end
    end
  end
end
