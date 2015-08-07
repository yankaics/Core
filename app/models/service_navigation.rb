class ServiceNavigation < ActiveRecord::Base
  has_attached_file :icon
  validates_attachment_content_type :icon, content_type: /\Aimage/
  validates_attachment_file_name :icon, matches: [/png\Z/, /jpe?g\Z/, /svg\Z/]
  has_attached_file :background_image
  validates_attachment_content_type :background_image, content_type: /\Aimage/
  validates_attachment_file_name :background_image, matches: [/png\Z/, /jpe?g\Z/, /svg\Z/]
  has_attached_file :background_pattern
  validates_attachment_content_type :background_pattern, content_type: /\Aimage/
  validates_attachment_file_name :background_pattern, matches: [/png\Z/, /jpe?g\Z/, /svg\Z/]

  validates :name, :url, :order, :index_order, :index_size, presence: true
end
