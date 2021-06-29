class Event < ApplicationRecord
  enum frequency: %i[daily weekly monthly yearly]
  belongs_to :user

  validates :title, presence: true
  validates :start, presence: true
  validates :end, presence: true
end
