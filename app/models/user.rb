class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  # Restrict deleting users who have bookings by returning an error instead of destroying
  has_many :bookings, dependent: :restrict_with_error

  # Enums
  enum :role, { user: 0, admin: 1 }, default: :user

  # Validations
  validates :name, presence: true
  validates :role, presence: true

  # Ransack configuration for searching users in admin panel
  def self.ransackable_attributes(auth_object = nil)
    %w[id name email role created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[bookings]
  end
end
