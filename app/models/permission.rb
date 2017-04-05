class Permission < ApplicationRecord
  belongs_to :accessible, polymorphic: true
  belongs_to :permittable, polymorphic: true

  PERMISSIONS = [:r, :w, :x]

  def permissions=(permissions)
    PERMISSIONS.each { |p| self.send(p.to_s+'=', permissions.include?(p)) }
  end

  def permissions
    PERMISSIONS.select { |p| self.send(p) }
  end

  def has_permission?(permission)
    permissions.include?(permission)
  end
end
