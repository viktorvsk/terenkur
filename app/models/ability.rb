class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all
    return unless user

    if user.admin?
      can :manage, :all
    else
      can :take_part, Event
      can :create_comment, Event
      cannot :take_part, Event, user_id: user.id
      can :manage, Event, user_id: user.id
      can :manage, User, id: user.id
    end

  end
end
