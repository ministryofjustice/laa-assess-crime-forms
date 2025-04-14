class UsersController < ApplicationController
  before_action :authorize_supervisor
  before_action :set_default_table_sort_options, only: %i[index]

  DEFAULT_SORT = 'name'.freeze

  def index
    pagy, users = pagy_array(sorted_users)

    render :index, locals: { pagy:, users: }
  end

  def new
    @form_object = UserForm.new
  end

  def edit
    @user = User.find(controller_params['id'])
    user = @user.attributes.slice('first_name', 'last_name', 'email')
    role = @user.roles.first
    @form_object = UserForm.new(user.merge({ role_type: role.role_type,
                                             caseworker_service: role.service,
                                             viewer_service: role.service }))
  end

  def create
    @form_object = UserForm.new(form_params)

    if @form_object.save
      redirect_to users_path
    else
      render :new
    end
  end

  def update
    user = User.find(controller_params['id'])
    @form_object = UserForm.new(form_params.merge({ id: user.id, email: user.email }))

    if @form_object.save
      redirect_to users_path
    else
      render :edit
    end
  end

  private

  def sorted_users
    direction = @sort_direction == 'descending' ? :desc : :asc
    case @sort_by
    when 'name'
      User.order(first_name: direction, last_name: direction)
    when 'role'
      User.includes(:roles).order(roles: { role_type: direction })
    when 'service'
      User.includes(:roles).order(roles: { service: direction })
    else
      User.order(params[:sort_by] => direction)
    end
  end

  def authorize_supervisor
    authorize :user_management, :show?
  end

  def controller_params
    params.permit(
      :id,
      :sort_by,
      :sort_direction,
      :page
    )
  end

  def form_params
    allowed_params = [:first_name,
                      :last_name,
                      :role_type,
                      :caseworker_service,
                      :viewer_service]

    allowed_params << :email unless action_name == 'update'

    params.expect(
      user_form: allowed_params,
    )
  end

  def param_validator
    @param_validator ||= UsersParams.new(controller_params)
  end

  def set_default_table_sort_options
    @sort_by = controller_params.fetch(:sort_by, DEFAULT_SORT)
    @sort_direction = controller_params.fetch(:sort_direction, 'ascending')
  end
end
