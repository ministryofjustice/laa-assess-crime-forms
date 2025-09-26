module RouteHelpers
  def edit_step(name, opts = {})
    resource name,
             only: opts.fetch(:only, [:edit, :update]),
             controller: name,
             path_names: { edit: '' }
  end

  def show_step(name)
    resource name, only: [:show], controller: name
  end
end
