class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :manage, Event, user_id: user.id
      can :manage, User, id: user.id
    end

  end
end
