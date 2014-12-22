ActiveAdmin.register_page "Setting" do
  menu priority: 100, label: I18n.t(:'activerecord.models.setting')

  content do

    form :action => admin_setting_update_path, :method => :post do |f|
      f.input :name => 'authenticity_token', :type => :hidden, :value => form_authenticity_token.to_s

      # Setting form helper methods

      def f.input_setting(label_text, setting_name)
        label label_text
        input :name => "setting[#{setting_name.to_s}]", :type => 'text', :value => Setting[setting_name]
      end

      def f.textarea_setting(label_text, setting_name)
        label label_text
        textarea :name => "setting[#{setting_name.to_s}]" do
          Setting[setting_name]
        end
      end

      def f.checkbox_setting(label_text, setting_name)
        label label_text
        input :id => "cb-#{setting_name.to_s}", :type => 'checkbox', :onchange => "if (this.checked) { document.getElementById('ip-#{setting_name.to_s}').value = 'true'; } else { document.getElementById('ip-#{setting_name.to_s}').value = 'false'; }", "#{Setting[setting_name] ? 'checked' : 'not_checked'}" => 'checked'
        input :name => "setting[#{setting_name.to_s}]", :id => "ip-#{setting_name.to_s}", :type => 'hidden'
      end

      # Setting form

      panel "System Settings" do
        fieldset do
          ol do

            li do
              f.checkbox_setting '維修模式', 'maintenance_mode'
            end

            li do
              f.textarea_setting '全站公告 (支援 markdown 語法)', :site_announcement
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
              f.input_setting '頁腳內容，可使用 HTML，例如： <a class="item" href="/">回首頁</a>', :page_footer
            end

          end
        end
      end

      panel "Admin Dashboard Settings" do
        fieldset do
          ol do

            li do
              f.input_setting 'App Monitor URL', :admin_app_monitor_url
            end

            li do
              f.input_setting 'Web Transactions Chart Code', :admin_web_transactions_chart_code
            end

            li do
              f.input_setting 'Apdex Score Chart Code', :admin_apdex_score_chart_code
            end

            li do
              f.input_setting 'Throughput Chart Code', :admin_throughput_chart_code
            end

            li do
              f.input_setting 'Error Rate Chart Code', :admin_error_rate_chart_code
            end

          end
        end
      end

      f.input :type => 'submit', :value => '更新'
    end
  end

  page_action :update, :method => :post do
    params['setting'].each do |k, v|
      v = true if v.to_s == 'true'
      v = false if v.to_s == 'false'
      Setting[k] = v
    end
    redirect_to :back, :notice => "設定已更新"
  end
end
