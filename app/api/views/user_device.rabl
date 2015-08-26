object @user_device || @user_devices

set_fieldset :user_device, default_fields: [:user_id, :uuid, :type, :name, :device_id],
                           permitted_fields: [:user_id, :uuid, :type, :name, :device_id]
set_inclusion :user_device

attributes(*(fieldset(:user_device) - inclusion_field(:user_device).keys))

node :_type do
  :user_device
end

extends('extensions/meta_data', locals: { self_resource: :user_device })
