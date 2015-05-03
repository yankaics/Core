if @meta.is_a?(Hash) && @meta[locals[:self_resource]].present?
  node :_meta do
    @meta[locals[:self_resource]]
  end
end
