module StepsHelper
  def step_form(record, options = {}, &block)
    default_url = {
      controller: controller.controller_path,
      action: :update
    }
    default_url[:return_to_cya] = 1 if params[:return_to_cya].present?

    opts = {
      url: default_url,
      method: :put
    }.merge(options)

    # :nocov:
    opts[:url] = default_url.merge(opts[:url]) if opts[:url].is_a?(Hash)
    # :nocov:

    form_for record, opts, &block
  end

  def step_header(path:)
    render partial: 'layouts/step_header', locals: { path: }
  end
end
