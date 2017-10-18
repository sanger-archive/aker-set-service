class Aker::Set < ApplicationRecord

  has_many :set_materials, foreign_key: :aker_set_id, dependent: :destroy
  has_many :materials, through: :set_materials, source: :aker_material

  validates :name, presence: true, uniqueness: true

  validate :validate_locked, if: :locked_was

  before_save :strip_name
  before_validation :strip_name

  def validate_locked
    errors.add(:base, "Set is locked") unless changes.empty?
  end

  def clone(newname, owner_email)
    copy = Aker::Set.create(name: newname, locked: false, owner_id: owner_email)
    copy.materials += materials
    copy
  end

  def permitted?(username, access)
    (access.to_sym==:read || owner_id.nil? || (username.is_a?(String) ? owner_id==username : username.include?(owner_id) ))
  end

  def strip_name
    stripped = name&.strip
    if stripped != name
      self.name = stripped
    end
  end

end
