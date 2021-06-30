require 'rails_helper'

RSpec.describe Event, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:start) }
  it { should validate_presence_of(:end) }
  it { should define_enum_for(:frequency).with_values(daily: 0, weekly: 1, monthly: 2, yearly: 3) }
end
