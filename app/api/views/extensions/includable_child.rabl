if include[locals[:self_resource]].include?(locals[:resource]) || locals[:included]
  child locals[:resource], root: locals[:resource], object_root: false do
    template = (locals[:model] || locals[:resource]).to_s.singularize
    extends template
  end
else
  node locals[:resource] do |obj|
    obj.send(locals[:unicode])
  end
end if fields[locals[:self_resource]].include?(locals[:resource])
