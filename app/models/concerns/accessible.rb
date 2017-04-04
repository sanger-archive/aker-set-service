require 'active_support/concern'

module Accessible
  extend ActiveSupport::Concern

  included do
    has_many :permissions, as: :accessible

    def set_permission(owner_email)
      self.permissions.create(permitted: owner_email, permissions: [:r, :w])
      self.permissions.create(permitted: 'world', permissions: [:r])
    end
  end

end
