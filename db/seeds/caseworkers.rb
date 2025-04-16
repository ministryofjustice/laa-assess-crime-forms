return unless ENV.fetch('ENV', 'local').in?(%w[development local])

User
  .find_or_initialize_by(email: 'case.worker@test.com')
  .update(
    first_name: 'Case',
    last_name: 'Worker',
    auth_oid: SecureRandom.uuid,
    auth_subject_id: SecureRandom.uuid,
    roles: [Role.new(role_type: 'caseworker', service: 'all')]
  )

User
  .find_or_initialize_by(email: 'super.visor@test.com')
  .update(
    first_name: 'Super',
    last_name: 'Visor',
    auth_oid: SecureRandom.uuid,
    auth_subject_id: SecureRandom.uuid,
    roles: [Role.new(role_type: 'supervisor', service: 'all')]
  )

User
  .find_or_initialize_by(email: 'viewer@test.com')
  .update(
    first_name: 'Reid',
    last_name: "O'Nly",
    auth_oid: SecureRandom.uuid,
    auth_subject_id: SecureRandom.uuid,
    roles: [Role.new(role_type: 'viewer', service: 'all')]
  )

User
  .find_or_initialize_by(email: 'pa@test.com')
  .update(
    first_name: 'Crim',
    last_name: 'Fours',
    auth_oid: SecureRandom.uuid,
    auth_subject_id: SecureRandom.uuid,
    roles: [Role.new(role_type: 'caseworker', service: 'pa')]
  )

User
  .find_or_initialize_by(email: 'nsm@test.com')
  .update(
    first_name: 'Crim',
    last_name: 'Sevens',
    auth_oid: SecureRandom.uuid,
    auth_subject_id: SecureRandom.uuid,
    roles: [Role.new(role_type: 'caseworker', service: 'nsm')]
  )
