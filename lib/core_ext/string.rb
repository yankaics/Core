require 'uri'

class String

  def add_uri_param(param_name, param_value)
    uri = URI(self)
    params = URI.decode_www_form(uri.query || '') << [param_name, param_value]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def add_or_replace_uri_param(param_name, param_value)
    uri = URI(self)
    params = URI.decode_www_form(uri.query || '')
    params.delete_if { |param| param[0].to_s == param_name.to_s }
    params << [param_name, param_value]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
