class Aker::Material < ApplicationRecord
  has_many :set_materials, foreign_key: :aker_material_id
  has_many :sets, through: :set_materials, source: :aker_set

  validates :id, presence: true, on: :create

  def self_link
    "#{Rails.configuration.materials_service_url}/materials/#{id}"
  end
end
