class Material

  def self.site
    Faraday.new(url: Rails.configuration.materials_service_url) do |faraday|
      faraday.use ZipkinTracer::FaradayHandler, 'eve'
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  def self.valid?(uuids)
    response = Material.site.post do |req|
      req.url '/materials/validate'
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.body = { materials: uuids }.to_json
    end

    response.body == 'ok'
  end

end