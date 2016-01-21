class AddEnabledToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :enabled, :boolean, default: true, null: false

    Organization.transaction do
      Organization.all.each do |org|
        org.enabled = true
        org.save(validate: false)
      end
    end
  end
end
