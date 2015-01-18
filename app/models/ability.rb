class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all
    return unless user

    if user.admin?
      can :manage, :all
    else

      can :manage, Event, user_id: user.id
      can :manage, User, id: user.id
    end

  end
end
