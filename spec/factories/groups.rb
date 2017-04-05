FactoryGirl.define do
  factory :group do
    name 'Group'
    initialize_with { Group.find_or_create_by(name: name) }
  end
end
