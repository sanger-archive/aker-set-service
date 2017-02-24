class Aker::SetMaterial < ApplicationRecord
  belongs_to :aker_set, class_name: "Aker::Set"
  belongs_to :aker_material, class_name: "Aker::Material"

  validate :lock_validation

  def lock_validation
    return true unless aker_set.locked || aker_set.locked_was
    errors.add(:base, "Set is locked")
    false
  end

end
