FactoryBot.define do
  factory :role do
    user { nil }

    trait :supervisor do
      role_type { 'supervisor' }
      service { 'all' }
    end

    trait :caseworker do
      role_type { 'caseworker' }
      service { 'all' }
    end

    trait :viewer do
      role_type { 'viewer' }
      service { 'all' }
    end
  end
end
