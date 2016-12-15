class Aker::Material < ApplicationRecord
  has_many :set_materials, foreign_key: :aker_material_id
  has_many :sets, through: :set_materials, source: :aker_set

  validates :id, presence: true, on: :create
end
