FactoryBot.define do
  attach_authentication_state = lambda do |user, context|
    user.assign_attributes(
      auth_subject_id: context.auth_subject_id,
      first_auth_at: context.first_auth_at,
      last_auth_at: context.last_auth_at,
      silas_user_name: context.silas_user_name,
      silas_roles_last_synced_at: context.silas_roles_last_synced_at
    )

    if context.auth_subject_id
      user.authentication_identities.build(
        provider: 'azure_ad',
        subject: context.auth_subject_id,
        first_authenticated_at: context.first_auth_at,
        last_authenticated_at: context.last_auth_at
      )
    end

    if context.silas_user_name
      user.authentication_identities.build(
        provider: 'silas',
        subject: context.silas_user_name,
        first_authenticated_at: context.first_auth_at,
        last_authenticated_at: context.last_auth_at,
        roles_synced_at: context.silas_roles_last_synced_at
      )
    end

    context.silas_roles.each do |role|
      user.silas_roles << role
    end
  end

  factory :caseworker, class: 'User' do
    email { Faker::Internet.email }
    first_name { 'case' }
    last_name { 'worker' }
    auth_oid { SecureRandom.uuid }
    roles { [build(:role, :caseworker)] }

    transient do
      auth_subject_id { SecureRandom.uuid }
      first_auth_at { Time.current }
      last_auth_at { Time.current }
      silas_user_name { nil }
      silas_roles { [] }
      silas_roles_last_synced_at { Time.current }
    end

    after(:build) { |user, context| attach_authentication_state.call(user, context) }

    trait :deactivated do
      deactivated_at { Time.zone.now }
    end
  end

  factory :supervisor, class: 'User' do
    email { Faker::Internet.email }
    first_name { 'super' }
    last_name { 'visor' }
    auth_oid { SecureRandom.uuid }
    roles { [build(:role, :supervisor)] }

    transient do
      auth_subject_id { SecureRandom.uuid }
      first_auth_at { Time.current }
      last_auth_at { Time.current }
      silas_user_name { nil }
      silas_roles { [] }
      silas_roles_last_synced_at { Time.current }
    end

    after(:build) { |user, context| attach_authentication_state.call(user, context) }
  end

  factory :viewer, class: 'User' do
    email { Faker::Internet.email }
    first_name { 'cannot' }
    last_name { 'edit' }
    roles { [build(:role, :viewer)] }

    transient do
      auth_subject_id { SecureRandom.uuid }
      first_auth_at { Time.current }
      last_auth_at { Time.current }
      silas_user_name { nil }
      silas_roles { [] }
      silas_roles_last_synced_at { Time.current }
    end

    after(:build) { |user, context| attach_authentication_state.call(user, context) }
  end
end
