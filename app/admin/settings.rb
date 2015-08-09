ActiveAdmin.register_page "Settings" do
  menu priority: 10000, label: I18n.t(:'activerecord.models.settings'), if: proc { current_admin.root? }

  content do

    if current_admin.root?
      Settings.reload

      form :action => admin_settings_update_path, :method => :post do |f|
        f.input :name => 'authenticity_token', :type => :hidden, :value => form_authenticity_token.to_s

        # Settings form helper methods

        def f.input_setting(label_text, settings_name, hint: nil)
          label label_text
          input :name => "settings[#{settings_name.to_s}]", :type => 'text', :value => Settings[settings_name]
          if hint.present?
            para class: 'inline-hints' do
              hint
            end
          end
        end

        def f.textarea_setting(label_text, settings_name, hint: nil)
          label label_text
          textarea :name => "settings[#{settings_name.to_s}]" do
            Settings[settings_name]
          end
          if hint.present?
            para class: 'inline-hints' do
              hint
            end
          end
        end

        def f.checkbox_setting(label_text, settings_name)
          label label_text
          input :id => "cb-#{settings_name}", :type => 'checkbox', :onchange => "if (this.checked) { document.getElementById('ip-#{settings_name}').value = 'true'; } else { document.getElementById('ip-#{settings_name}').value = 'false'; }", :onload => "alert('aa')", "#{Settings[settings_name] ? 'checked' : 'not_checked'}" => 'checked'
          input :name => "settings[#{settings_name}]", :id => "ip-#{settings_name}", :type => 'hidden'
          script type: 'text/javascript' do
            "$('#cb-#{settings_name}').change();".html_safe
          end
        end

        # Settings form

        panel "System Settings" do
          fieldset do
            ol do

              li do
                f.checkbox_setting '維修模式', 'maintenance_mode'
              end

              li do
                f.textarea_setting '全站公告', :site_announcement, hint: '支援 markdown 語法'
              end

            end
          end
        end

        panel "Site Settings" do
          fieldset do
            ol do

              li do
                f.textarea_setting 'LOGO (可以是圖片網址、或是 svg 向量圖)', :app_logo
              end

              li do
                f.input_setting '頁腳內容', :page_footer, hint: '可使用 HTML，例如： <a class="item" href="/">回首頁</a>'
              end

              li do
                f.textarea_setting 'Site EULA (supports Markdown)', :site_eula
              end

              li do
                f.textarea_setting '服務特色文案', :service_features
              end

            end
          end
        end

        panel "Advance System Settings" do
          fieldset do
            ol do

              li do
                f.textarea_setting 'Facebook App IDs', :fb_app_ids, hint: '允許透過 Facebook Access Token 登入取得最高權限的 Facebook App ID 白名單，一行一個'
              end

            end
          end
        end

        panel "Admin Dashboard Settings" do
          fieldset do
            ol do

              # li do
              #   f.input_setting 'Title of Left-1 Chart', :admin_dashboard_l1_chart_title
              # end

              # li do
              #   f.input_setting 'Title URL of Left-1 Chart', :admin_dashboard_l1_chart_title_url
              # end

              li do
                f.input_setting "Code of Left-1 Chart", "admin_dashboard_l1_chart_code"
              end

              (2..8).each do |i|

                li do
                  f.input_setting "Title of Left-#{i} Chart", "admin_dashboard_l#{i}_chart_title"
                end

                li do
                  f.input_setting "Title URL of Left-#{i} Chart", "admin_dashboard_l#{i}_chart_title_url"
                end

                li do
                  f.input_setting "Code of Left-#{i} Chart", "admin_dashboard_l#{i}_chart_code"
                end

              end

              li do
                f.input_setting 'Title of Right-1 Chart', :admin_dashboard_r1_chart_title
              end

              li do
                f.input_setting 'Title URL of Right-1 Chart', :admin_dashboard_r1_chart_title_url
              end

              li do
                f.input_setting 'Code of Right-1 Chart', :admin_dashboard_r1_chart_code
              end

              (2..8).each do |i|

                li do
                  f.input_setting "Title of Right-#{i} Chart", "admin_dashboard_r#{i}_chart_title"
                end

                li do
                  f.input_setting "Title URL of Right-#{i} Chart", "admin_dashboard_r#{i}_chart_title_url"
                end

                li do
                  f.input_setting "Code of Right-#{i} Chart", "admin_dashboard_r#{i}_chart_code"
                end

              end

            end
          end
        end

        f.input :type => 'submit', :value => '更新'
      end
    end
  end

  page_action :update, :method => :post do
    if current_admin.root?
      params['settings'].each do |k, v|
        v = true if v.to_s == 'true'
        v = false if v.to_s == 'false'
        Settings[k] = v
      end
      redirect_to :back, :notice => "設定已更新"
    end
  end
end
