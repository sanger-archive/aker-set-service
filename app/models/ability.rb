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
    accessible.permissions.exists?(['permitted = ? AND permissions_mask >= ?', user_data['user']['email'], Permission.permission_bit(access)]) ||
    accessible.permissions.exists?(['permitted IN (?) AND permissions_mask >= ?', user_data['groups'], Permission.permission_bit(access)])
  end
end
