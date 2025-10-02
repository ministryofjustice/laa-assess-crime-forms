module StepsHelper
  def step_form(record, options = {}, &block)
    opts = {
      url: { controller: controller.controller_path, action: :update },
      method: :put
    }.merge(options)

    form_for record, opts, &block
  end

  def step_header(path:)
    render partial: 'layouts/step_header', locals: { path: }
  end
end
