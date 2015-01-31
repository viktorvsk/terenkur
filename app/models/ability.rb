class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all
    if user
      if user.admin?
        can :manage, :all
      else
        can :take_part, Event
        can :create_comment, Event
        can :destroy_comment, Event
        cannot :destroy, Comment
        can :destroy, Comment, user_id: user.id
        cannot :take_part, Event, user_id: user.id
        can :manage, Event, user_id: user.id
        can :manage, User, id: user.id
        cannot [:register, :new], User
      end
    else
      can [:register, :new], User
    end

  end
end
