class Event < ApplicationRecord
  enum frequency: %i[daily weekly monthly yearly]
  belongs_to :user

  validates :title, :start, :end, presence: true
end
