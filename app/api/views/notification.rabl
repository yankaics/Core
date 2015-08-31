object @notification || @notifications

set_fieldset :notification, default_fields: [:uuid, :user_id, :application_id, :subject, :message, :url, :payload, :checked_at, :clicked_at, :created_at, :updated_at],
                            permitted_fields: [:uuid, :user_id, :application_id, :subject, :message, :url, :payload, :checked_at, :clicked_at, :created_at, :updated_at]
set_inclusion :notification

attributes(*(fieldset(:notification) - inclusion_field(:notification).keys))

node :_type do
  :notification
end

extends('extensions/meta_data', locals: { self_resource: :notification })
