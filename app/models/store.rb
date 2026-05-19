class Store < ApplicationRecord
  # Associations
  has_many :bookings, dependent: :restrict_with_error

  # Enums
  enum :status, { active: 0, inactive: 1 }, default: :active

  # Validations
  validates :name, presence: true
  validates :address, presence: true
  validates :opening_time, presence: true
  validates :closing_time, presence: true
  validates :booking_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  validate :working_hours_validations
  validate :cannot_update_with_approved_bookings, on: :update

  # Scopes
  scope :active, -> { where(status: :active) }

  # Ransack configuration for searching stores in views
  def self.ransackable_attributes(auth_object = nil)
    %w[id name address status booking_fee opening_time closing_time created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[bookings]
  end

  private

  def working_hours_validations
    return unless opening_time.present? && closing_time.present?

    # Format times as "HH:MM" for robust text/time comparison
    open_str = opening_time.strftime("%H:%M")
    close_str = closing_time.strftime("%H:%M")

    if open_str < "08:00"
      errors.add(:opening_time, "cannot be earlier than 08:00")
    end

    if close_str > "17:00"
      errors.add(:closing_time, "cannot be later than 17:00")
    end

    if close_str <= open_str
      errors.add(:closing_time, "must be after the opening time")
    end
  end

  def cannot_update_with_approved_bookings
    if bookings.approved.exists?
      errors.add(:base, I18n.t("app_messages.models.store.update_with_approved_bookings"))
    end
  end
end
