object false

@sms.keys.each do |key|
  node(key){ @sms[key] }
end if @sms

extends('extensions/meta_data', locals: { self_resource: :department })
