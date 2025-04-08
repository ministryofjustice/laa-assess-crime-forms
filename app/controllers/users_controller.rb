class UsersController < ApplicationController
  before_action :authorize_supervisor
  before_action :set_default_table_sort_options, only: %i[show]

  DEFAULT_SORT = 'name'.freeze

  def show
    pagy, records = pagy_array(users)

    render :index, locals: { pagy: pagy, users: records }
  end

  private

  def users
    direction = @sort_direction == 'descending' ? :desc : :asc
    case @sort_by
    when 'name'
      User.order(first_name: direction, last_name: direction)
    when 'role'
      User.joins(:roles)
          .select('users.*, roles.role_type')
          .distinct
          .order("roles.role_type #{direction}")
    else
      User.order(params[:sort_by] => direction)
    end
  end

  def authorize_supervisor
    authorize :dashboard, :show?
  end

  def controller_params
    params.permit(
      :sort_by,
      :sort_direction,
      :page
    )
  end

  def param_validator
    @param_validator ||= UsersParams.new(controller_params)
  end

  def set_default_table_sort_options
    @sort_by = controller_params.fetch(:sort_by, DEFAULT_SORT)
    @sort_direction = controller_params.fetch(:sort_direction, 'descending')
  end
end
