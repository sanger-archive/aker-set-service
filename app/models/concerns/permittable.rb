require 'active_support/concern'

module Permittable
  extend ActiveSupport::Concern

  included do
    has_many :permissions, as: :permittable
  end

end
