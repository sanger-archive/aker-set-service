class Permission < ApplicationRecord
  belongs_to :accessible, polymorphic: true
  belongs_to :user

  PERMISSIONS = [:r, :w, :x]

  def permissions=(permissions)
    permissions = [*permissions].map { |p| p.to_sym }
    self.permissions_mask = (permissions & PERMISSIONS).map { |r| Permission.permission_bit(r) }.inject(0, :+)
  end

  def self.permission_bit(permission)
    return 1<<PERMISSIONS.index(permission)
  end

  def permissions
    PERMISSIONS.reject do |r|
      ((permissions_mask.to_i || 0) & Permission.permission_bit(r)).zero?
    end
  end

  def has_permission?(permission)
    permissions.include?(permission)
  end
end
