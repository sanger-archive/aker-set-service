require 'rest-client'

class Material

  def self.site
    RestClient::Resource.new(Rails.configuration.materials_service_url)
  end

  def self.valid?(uuids)
    response = Material.site["materials"]["validate"].post( { materials: uuids }.to_json, { content_type: :json, accept: :json })
    response.body == 'ok'
  end

end