class Booking < ApplicationRecord
  acts_as_paranoid
  # Associations
  belongs_to :user
  belongs_to :store

  # Enums
  enum :status, { approved: 0, cancelled: 1, completed: 2 }, default: :approved

  # Validations
  validates :booking_date, presence: true
  validates :booking_time, presence: true
  validates :status, presence: true

  validate :booking_date_not_in_past, on: :create
  validate :booking_time_within_store_hours, on: :create
  validate :no_duplicate_booking_slot, on: :create
  validate :store_must_be_active, on: :create

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :completed, -> { where(status: :completed) }

  # Auto-completes approved bookings whose time slot has passed
  def self.auto_complete_passed!
    approved
      .where("TIMESTAMP(booking_date, booking_time) < ?", Time.current)
      .update_all(status: :completed, updated_at: Time.current)
  end

  # Ransack configuration for searching bookings in admin views
  def self.ransackable_attributes(auth_object = nil)
    %w[id user_id store_id booking_date booking_time status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user store]
  end

  private

  def booking_date_not_in_past
    return unless booking_date.present?

    if booking_date < Date.current
      errors.add(:booking_date, I18n.t("messages.models.booking.date_in_past"))
    elsif booking_date == Date.current && booking_time.present?
      # Combine booking_date and booking_time into a full Time object in application time zone
      booking_datetime = Time.zone.parse("#{booking_date} #{booking_time.strftime('%H:%M:%S')}")
      # Allow a tiny 5-minute buffer for form submission/click latency
      if booking_datetime < Time.current - 5.minutes
        errors.add(:booking_time, I18n.t("messages.models.booking.time_in_past"))
      end
    end
  end

  def booking_time_within_store_hours
    return unless booking_time.present? && store.present?

    # Compare time of day as "HH:MM" format
    booking_str = booking_time.strftime("%H:%M")
    open_str = store.opening_time.strftime("%H:%M")
    close_str = store.closing_time.strftime("%H:%M")

    if booking_str < open_str || booking_str > close_str
      errors.add(:booking_time, I18n.t("messages.models.booking.operating_hours", open: open_str, close: close_str))
    end
  end

  def no_duplicate_booking_slot
    return unless booking_date.present? && booking_time.present? && store.present?

    # Find existing non-cancelled bookings at the same store on the same day
    conflicting_bookings = Booking.where(
      store_id: store_id,
      booking_date: booking_date,
      status: [ :approved, :completed ]
    )

    # Exclude the current booking when updating
    conflicting_bookings = conflicting_bookings.where.not(id: id) if persisted?

    booking_time_str = booking_time.strftime("%H:%M")
    has_conflict = conflicting_bookings.any? do |b|
      b.booking_time.strftime("%H:%M") == booking_time_str
    end

    if has_conflict
      errors.add(:booking_time, I18n.t("messages.models.booking.duplicate_slot"))
    end
  end

  def store_must_be_active
    return unless store.present?

    if store.inactive?
      errors.add(:store, I18n.t("messages.models.booking.inactive_store"))
    end
  end
end
