class UserForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

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
  validates :role_type, presence: true, inclusion: { in: Role::ROLE_TYPES }
  validates :caseworker_service, inclusion: { in: Role.services, allow_nil: true }
  validates :viewer_service, inclusion: { in: Role.services, allow_nil: true }

  def save
    return false unless valid?

    if id.nil?
      create_user
    else
      update_user
    end
  end

  private

  def create_user
    User.create!(
      first_name: first_name,
      last_name: last_name,
      email: email,
      auth_oid: SecureRandom.uuid,
      roles: [Role.new(role_type:, service:)]
    )
  end

  def update_user
    User.find(id).update!(first_name: first_name,
                          last_name: last_name,
                          email: email,
                          roles: [Role.new(role_type:, service:)])
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
