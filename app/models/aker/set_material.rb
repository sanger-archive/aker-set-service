class Aker::SetMaterial < ApplicationRecord
  belongs_to :aker_set, class_name: "Aker::Set"
  belongs_to :aker_material, class_name: "Aker::Material"
end
