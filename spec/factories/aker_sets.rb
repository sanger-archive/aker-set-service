FactoryGirl.define do
  factory :aker_set, class: 'Aker::Set' do
    sequence(:name) { |n| "Set #{n}" }
    owner_id "user@here.com"

    after(:create) do |set, evaluator|
      set.set_default_permission(set.owner_id)
    end

    factory :set_with_materials do

      transient do
        materials_count 5
      end

      after(:create) do |set, evaluator|
        evaluator.materials_count.times { set.materials << create(:aker_material) }
      end

    end
  end
end
