class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.admin?
        can :manage, :all
      else
        can :take_part, Event
        can :create_comment, Event
        cannot :take_part, Event, user_id: user.id
        can :manage, Event, user_id: user.id
        can :manage, User, id: user.id
        cannot [:register, :new], User
      end
    else
      can :read, :all
      can [:register, :new], User
    end

  end
end
