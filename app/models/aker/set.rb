class Aker::Set < ApplicationRecord
  include AkerAuthorisationGem::Accessible

  has_many :set_materials, foreign_key: :aker_set_id, dependent: :destroy
  has_many :materials, through: :set_materials, source: :aker_material

  validates :name, presence: true, uniqueness: true

  validate :validate_locked, if: :locked_was

  def validate_locked
    errors.add(:base, "Set is locked") unless changes.empty?
  end

  def clone(newname, owner_email)
    copy = Aker::Set.create(name: newname, locked: false)
    copy.set_permission(owner_email)
    copy.materials += materials
    copy
  end

  def owner=(owner)
    owner_id=owner
  end
end
