JSONAPI.configure do |config|
  #:underscored_key, :camelized_key, :dasherized_key, or custom
  config.json_key_format = :underscored_key
  #:integer, :uuid, :string, or custom (provide a proc)
  config.resource_key_type = :uuid
  # optional request features
  config.allow_include = false
end