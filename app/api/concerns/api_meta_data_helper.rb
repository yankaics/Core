module APIMetaDataHelper
  def meta
    @meta ||= ActiveSupport::HashWithIndifferentAccess.new
  end
end
