if meta[locals[:self_resource]].present?
  node :_meta do
    meta[locals[:self_resource]]
  end
end
