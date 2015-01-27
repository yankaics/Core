ActiveAdmin.register Doorkeeper::Application do
  menu priority: 50, label: "應用程式", if: proc { current_admin.root? }
  scope_to(if: proc { current_admin.scoped? }) { current_admin }

  scope :all
  scope :core_apps, :default => true
  scope :user_apps

  index do
    selectable_column
    id_column
    column :name do |app|
      link_to app.name, admin_doorkeeper_application_path(app)
    end
    column :owner_type do |app|
      if app.owner_type == 'User'
        status_tag('User', :class => 'User')
      else
        status_tag(app.owner_type, :class => app.owner_type)
      end
    end
    column :owner
    column :redirect_uri
    column :created_at
    column :sms_quota

    actions
  end

  form do |f|
    f.inputs "Info" do
      f.input :name
      f.input :description
      f.input :app_url
    end
    f.inputs "Owner" do
      f.input :owner_type
      f.input :owner_id
    end
    f.inputs "Credentials" do
      f.input :secret
      f.input :redirect_uri
    end
    f.inputs "Permissions" do
      f.input :blocked
      # f.input :scopes
      f.input :sms_quota
    end
    f.actions
  end

  controller do
    def oauth_application_params
      params.require(:doorkeeper_application).permit(:name, :description, :app_url, :redirect_uri, :scopes, :blocked, :sms_quota, :owner_id, :owner_type, :owner, :secret)
    end

    def update
      @doorkeeper_application = Doorkeeper::Application.find(params[:id])

      if @doorkeeper_application.update(oauth_application_params)
        redirect_to admin_doorkeeper_application_path(@doorkeeper_application)
      else
        render :edit
      end
    end

    def new
      @doorkeeper_application = current_admin.oauth_applications.new
      @doorkeeper_application.send :generate_secret
    end

    def create
      @doorkeeper_application = current_admin.oauth_applications.new(oauth_application_params)
      if @doorkeeper_application.save
        redirect_to admin_doorkeeper_application_path(@doorkeeper_application)
      else
        render :new
      end
    end
  end
end
