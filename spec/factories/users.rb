FactoryGirl.define do
  factory :user do
    email 'user@here.com'

    initialize_with { User.find_or_create_by(email: email) }
  end
end
