class User < ApplicationRecord
  has_many :events
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable

  def name
    read_attribute(:name).blank? ? read_attribute(:name).capitalize : email.split('@')[0].capitalize
  end

  def author?(resource)
    resource.user_id == id
  end
end
