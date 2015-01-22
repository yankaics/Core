if @include[locals[:self_resource]].include?(locals[:resource])
  child locals[:resource] do
    extends(locals[:resource].to_s)
  end
else
  node locals[:resource] do |obj|
    obj.send(locals[:unicode])
  end
end if @fields[locals[:self_resource]].include?(locals[:resource])
