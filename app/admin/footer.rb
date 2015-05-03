module ActiveAdmin
  module Views
    class Footer < Component
      @@powered_by_message = nil
      @@commit_hash = nil

      def build
        super id: "footer"

        para "#{powered_by_message}".html_safe
      end

      private

      def powered_by_message
        return @@powered_by_message if @@powered_by_message.present?

        powered_bys = []
        powered_bys << link_to("Colorgy", "https://github.com/colorgy/Core", target: '_blank')
        powered_bys << ' '
        powered_bys << Core::VERSION
        powered_bys << '.' + commit_hash if commit_hash.present?
        powered_bys << ' '
        powered_bys << ' - '
        powered_bys << ' '
        powered_bys << link_to("Active Admin", "http://www.activeadmin.info", target: '_blank')
        powered_bys << ' '
        powered_bys << ActiveAdmin::VERSION

        @@powered_by_message = I18n.t('active_admin.powered_by',
          active_admin: powered_bys.join(''),
          version: nil)
      end

      def commit_hash
        return @@commit_hash if @@commit_hash.present?
        @@commit_hash = `git rev-parse --short HEAD`
        @@commit_hash ||= ''
      end
    end
  end
end
