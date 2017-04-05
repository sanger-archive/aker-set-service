require 'active_support/concern'

module Accessible
  extend ActiveSupport::Concern

  included do
    has_many :permissions, as: :accessible

    def set_permission(owner)
      world = Group.find_or_create_by(name: 'world')
      self.permissions.create(permittable: owner, permissions: [:r, :w])
      self.permissions.create(permittable: world, permissions: [:r])
    end
  end

end
