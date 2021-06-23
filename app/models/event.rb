class Event < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :start, presence: true
  validates :end, presence: true
end
