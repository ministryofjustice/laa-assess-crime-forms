class UserForm < BaseForm
  attribute :id
  attribute :first_name
  attribute :last_name
  attribute :email
  attribute :role_type
  attribute :caseworker_service
  attribute :viewer_service

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role_type, presence: true, inclusion: { in: (Role::ROLE_TYPES + ['none']) }
  validates :caseworker_service,
            inclusion: { in: Role.services },
            presence: true,
            if: -> { role_type == 'caseworker' }

  validates :viewer_service,
            inclusion: { in: Role.services },
            presence: true,
            if: -> { role_type == 'viewer' }
  def save
    return false unless valid?

    if id.nil?
      create_user
    else
      update_existing_user
      true
    end
  end

  private

  def create_user
    user = User.new(user_attributes)
    assign_local_role(user)
    user.save

    return true if user.errors.empty?

    user.errors.map { |error| errors.add(error.attribute.to_sym, error.type.to_sym) }

    false
  end

  def update_existing_user
    user = User.find(id)

    User.transaction do
      user.update!(user_attributes)
      user.roles.destroy_all
      assign_local_role(user)
    end
  end

  def user_attributes
    {
      first_name: first_name,
      last_name: last_name,
      email: email,
      auth_oid: SecureRandom.uuid,
      deactivated_at: (DateTime.now if role_type == 'none')
    }
  end

  def assign_local_role(user)
    return if role_type == 'none'

    role = user.roles.build(role_type:, service:)
    role.save! if user.persisted?
  end

  def service
    case role_type
    when 'caseworker'
      caseworker_service
    when 'viewer'
      viewer_service
    else
      'all'
    end
  end
end
