namespace :user do
  desc 'add user to database'
  task :add, [:email, :first_name, :last_name, :role, :service] => [:environment] do |_t, args|
    User.find_or_initialize_by(email: args[:email])
        .update!(
          first_name: args[:first_name],
          last_name: args[:last_name],
          auth_oid: SecureRandom.uuid,
          roles: [Role.new(role_type: args[:role_type], service: args[:service])]
        )
  end

  desc 'deactivate user (disable login)'
  task :deactivate, [:email] => [:environment] do |_t, args|
    abort("Usage: Run task with email as argument ie 'rake user:deactivate[test@test.com]'") unless args[:email]

    user = User.find_by(email: args[:email]) || abort('User not found')
    user.update!(deactivated_at: Time.now)

    puts "User email: #{user.email} deactivated at #{user.deactivated_at}"
  end

  desc 'reactivate user (re-enable disabled login)'
  task :reactivate, [:email] => [:environment] do |_t, args|
    abort("Usage: Run task with email as argument ie 'rake user:reactivate[test@test.com]'") unless args[:email]

    user = User.find_by(email: args[:email]) || abort('User not found')
    user.update!(deactivated_at: nil)

    puts "User email: #{user.email} reactivated"
  end
end
