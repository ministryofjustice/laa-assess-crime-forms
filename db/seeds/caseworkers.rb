return unless HostEnv.local? || HostEnv.development?

seed_users = [
  { email: 'case.worker@test.com', first_name: 'Case', last_name: 'Worker', role_type: 'caseworker', service: 'all' },
  { email: 'super.visor@test.com', first_name: 'Super', last_name: 'Visor', role_type: 'supervisor', service: 'all' },
  { email: 'viewer@test.com', first_name: 'Reid', last_name: "O'Nly", role_type: 'viewer', service: 'all' },
  { email: 'pa@test.com', first_name: 'Crim', last_name: 'Fours', role_type: 'caseworker', service: 'pa' },
  { email: 'nsm@test.com', first_name: 'Crim', last_name: 'Sevens', role_type: 'caseworker', service: 'nsm' }
]

seed_users.each do |attributes|
  user = User.find_or_initialize_by(email: attributes.fetch(:email))
  user.update!(
    attributes.slice(:first_name, :last_name).merge(
      auth_oid: SecureRandom.uuid,
      roles: [Role.new(role_type: attributes.fetch(:role_type), service: attributes.fetch(:service))]
    )
  )

  identity = user.authentication_identities.find_or_initialize_by(provider: 'azure_ad')
  identity.update!(
    subject: identity.subject.presence || SecureRandom.uuid,
    first_authenticated_at: identity.first_authenticated_at || Time.current,
    last_authenticated_at: Time.current
  )
end
