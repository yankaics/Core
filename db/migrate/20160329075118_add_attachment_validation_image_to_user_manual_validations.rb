class AddAttachmentValidationImageToUserManualValidations < ActiveRecord::Migration
  def self.up
    change_table :user_manual_validations do |t|
      t.attachment :validation_image
    end
  end

  def self.down
    remove_attachment :user_manual_validations, :validation_image
  end
end
