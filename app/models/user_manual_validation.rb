class UserManualValidation < ActiveRecord::Base
	belongs_to :user
	has_attached_file :validation_image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :validation_image, content_type: /\Aimage\/.*\Z/
end
