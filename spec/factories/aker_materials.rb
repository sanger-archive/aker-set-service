FactoryBot.define do
  factory :aker_material, class: 'Aker::Material' do
    id { SecureRandom.uuid }
  end
end
