# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
class Ability
  include CanCan::Ability

  def initialize(user_data)
    can :create, Accessible

    can :read, Accessible do |accessible|
      permitted?(accessible, user_data, :r)
    end

    can :write, Accessible do |accessible|
      permitted?(accessible, user_data, :w)
    end
  end

  def permitted?(accessible, user_data, access)
    user = user_data['user']
    groups = user_data['groups']
    return true unless accessible.permissions.select { |p| p.permittable==user && p.has_permission?(access) }.empty?
    return true unless accessible.permissions.select { |p| p.has_permission?(access) && groups.include?(p.permittable) }.empty?
    false
  end
end

