ActiveAdmin.register UserIdentity do
  menu priority: 113, parent: 'organization'
  config.sort_order = :organization_code_asc, :uid_asc
  config.per_page = 1000

  scope_to(if: proc { current_admin.scoped? }) { current_admin.organization }

  controller do
    before_action :set_current_admin

    def scoped_collection
      super#.includes(:user, :organization, :department, :original_department)
    end

    def set_current_admin
      Admin.current_admin = current_admin
    end
  end

  scope :all
  scope :generated
  scope :predefined, :default => true
  scope :linked
  scope :unlinked

  permit_params do
    params = [:name, :email, :identity, :uid, :department, :department_code, :original_department, :original_department_code, :permit_changing_department_in_group, :permit_changing_department_in_organization, :permit_changing_started_at, :skip_confirmation, :email_pattern, :email_pattern_id]
    params.concat [:organization_code, :organization] if current_admin.root?
    params
  end


  active_admin_import :validate => true,
                      :template => 'admin/import',
                      :template_object => ActiveAdminImport::Model.new(
                        hint: "CSV 欄位順序：身份別代碼（訪客: guest, 學生: student, 職員: staff, 講師: lecturer, 教授: professor）、名稱、email、唯一識別碼、系所代碼、組織代碼、可切換同型部門（選填，true/false）、可切換部門（選填，true/false）、原系所代碼（選填）",
                        csv_headers: %w(identity name email uid department_code organization_code permit_changing_department_in_group permit_changing_department_in_organization original_department_code)
                      ),
                      :before_batch_import => proc { |importer|
                        importer_csv_lines = importer.instance_variable_get(:@csv_lines)

                        # delete this line if it is an out-scoped line
                        # imported by a scoped Admin
                        importer_csv_lines.delete_if { |csv_line| Admin.current_admin.scoped? && Admin.current_admin.scoped_organization_code != csv_line[5] }

                        total_emails = importer_csv_lines.count

                        # delete this line if a predefined UserIdentity already exists and is linked
                        ignored_emails = []
                        emails = importer_csv_lines.map { |csv_line| csv_line[2] }
                        existing_linked_emails = UserIdentity.select(:email).where(email: emails).where('user_id IS NOT NULL AND email_pattern_id IS NULL').map(&:email)
                        importer_csv_lines.delete_if do |csv_line|
                          ignored = existing_linked_emails.include?(csv_line[2])
                          ignored_emails << csv_line[2] if ignored
                          ignored
                        end

                        # delete the existing duplicated and unlinked/generated UserIdentity
                        updated_emails = []
                        existing_unlinked_emails = UserIdentity.select(:email).where(email: emails).where('user_id IS NULL OR email_pattern_id IS NOT NULL').map(&:email)
                        importer_csv_lines.each do |csv_line|
                          updated_emails << csv_line[2] if existing_unlinked_emails.include?(csv_line[2])
                        end
                        UserIdentity.where(email: updated_emails).delete_all if updated_emails.present?

                        # preprocess each line
                        importer_csv_lines.each do |csv_line|
                          # convert identity string to integer for batch import
                          csv_line[0] = UserIdentity::IDENTITIES[csv_line[0].to_sym]

                          # set default value for unspecified columns
                          unspecified_column_count = importer.headers.count - csv_line.count
                          # permit_changing_department_in_group defaults to false
                          if unspecified_column_count == 3
                            csv_line.append(false)
                            unspecified_column_count -= 1
                          end
                          # permit_changing_department_in_group defaults to false
                          if unspecified_column_count == 2
                            csv_line.append(false)
                            unspecified_column_count -= 1
                          end
                          # original_department_code defaults to department_code
                          if unspecified_column_count == 1
                            csv_line.append(csv_line[4])
                            unspecified_column_count -= 1
                          end
                        end

                        # save the preprocessed lines
                        importer.instance_variable_set(:@csv_lines, importer_csv_lines)

                        # log the result
                        Rails.logger.info "UserIdentity batch import result: total #{total_emails}, ignored #{ignored_emails.count}, updated #{updated_emails.count}."
                        Rails.logger.info "UserIdentity batch import result: ignored: #{ignored_emails.join(', ')}." if ignored_emails.present?
                        Rails.logger.info "UserIdentity batch import result: updated: #{updated_emails.join(', ')}." if updated_emails.present?
                      },
                      :after_batch_import => proc { |importer|
                        importer_csv_lines = importer.instance_variable_get(:@csv_lines)
                        emails = importer_csv_lines.map { |csv_line| csv_line[2] }
                        UserEmail.includes(:associated_user_identity).where(email: emails).each(&:re_identify!)
                      }

  filter :organization, if: proc { current_admin.root? }
  filter :department
  filter :original_department
  filter :name
  filter :email
  filter :identity
  filter :uid
  filter :permit_changing_department_in_group
  filter :permit_changing_department_in_organization
  filter :permit_changing_started_at
  filter :created_at
  filter :updated_at

  sidebar "使用者身份" do
    para '使用者經由「使用者身份」關聯至組織與組織內的部門。一位使用者可擁有多重身份，並屬於多個組織。「使用者身份」可能由「電子郵件識別模型」自動解析 email 產生；或是手動輸入，當未來有使用者認證相同的 email 時，再連結到該使用者。'
    dl do
      dt '對應使用者'
      dd '目前擁有此身份的使用者。'
      dt '對應電子郵件識別模型'
      dd '若身份係由「電子郵件識別模型」產生，生成此身份的「電子郵件識別模型」。'
      dt '對應電子郵件'
      dd '開通此身份所需要認證的電子郵件。'
      dt '使用者名稱'
      dd '擁有此身份的使用者，預設的名稱。'
      dt '身份'
      dd '此身份的身份類型。'
      dt '所屬部門'
      dd '此身份的所屬部門。'
      dt '原所屬部門'
      dd '此身份的原所屬部門。'
      dt '可切換同型部門'
      dd '若設為「是」，則使用者可以更改此身份到同組織、同種類的任意部門。'
      dt '可切換部門'
      dd '若設為「是」，則使用者可以更改此身份到同組織的任意部門。'
    end
  end

  config.per_page = 100

  index do
    selectable_column
    column(:organization) { |user_identity| link_to user_identity.organization_code, admin_organization_path(user_identity.organization) } if current_admin.root?
    column(:department) { |user_identity| link_to user_identity.department_name, admin_department_path(user_identity.department) if user_identity.department }
    column(:original_department) { |user_identity| link_to user_identity.original_department_name, admin_department_path(user_identity.original_department) if user_identity.original_department }
    column(:user) { |user_identity| link_to user_identity.user.name, admin_user_path(user_identity.user) if user_identity.user }
    column(:name) { |user_identity| link_to user_identity.name, admin_user_identity_path(user_identity) if user_identity.name }
    column(:email) { |user_identity| link_to user_identity.email, admin_user_identity_path(user_identity) }
    column(:identity) { |user_identity| UserIdentity.human_enum_value(:identity, user_identity.identity) }
    column(:uid)
    column(:permit_changing_department_in_group)
    column(:permit_changing_department_in_organization)
    column(:permit_changing_started_at)
    id_column
    actions
  end

  form do |f|
    f.inputs do
      f.input :organization_code, as: :select, collection: options_for_select(Organization.all_for_select, user_identity.organization_code) if current_admin.root?
      f.input :department_code if current_admin.root?
      f.input :original_department_code if current_admin.root?
      f.input :department, as: :select, collection: options_for_select(current_admin.organization.departments_for_select, user_identity.department_code) unless current_admin.root?
      f.input :original_department, as: :select, collection: options_for_select(current_admin.organization.departments_for_select, user_identity.original_department_code) unless current_admin.root?
      f.input :name
      f.input :email
      f.input :identity, as: :select, collection: options_for_select(UserIdentity.identity_attributes_for_select, user_identity.identity)
      f.input :uid
      f.input :permit_changing_department_in_group
      f.input :permit_changing_department_in_organization
      f.input :permit_changing_started_at
      f.input :skip_confirmation
      f.input :email_pattern_id, hint: "User Identities with no belonging Email Pattern will be treated as predefined identity data, and will not be deleted if it's user deletes the corresponding email."
    end
    f.actions
  end
end
