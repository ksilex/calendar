FactoryBot.define do
  factory :event do
    title { 'title' }
    start {'2010-10-10'}
    add_attribute(:end) { '2010-10-11' }
    user
  end
  trait :invalid_event do
    title { nil }
  end
end
