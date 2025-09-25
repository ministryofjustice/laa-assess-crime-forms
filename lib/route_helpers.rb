module RouteHelpers
  def edit_step(name, opts = {}, &block)
    resource name,
             only: opts.fetch(:only, [:edit, :update]),
             controller: name,
             path_names: { edit: '' } do
      yield if block
    end
  end

  def show_step(name, &block)
    resource name, only: [:show], controller: name do
      yield if block
    end
  end
end
