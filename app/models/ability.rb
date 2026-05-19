# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Guests (unauthenticated users) cannot perform actions
    return unless user.present?

    if user.admin?
      # Admin Permissions
      can :manage, :all
    else
      # Regular User Permissions
      can :read, Store, status: "active"
      
      # Bookings: users can only view, create, or cancel their own bookings
      can :read, Booking, user_id: user.id
      can :create, Booking
      can :cancel, Booking, user_id: user.id, status: "approved"
    end
  end
end
