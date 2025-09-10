require Rails.root.join('lib/govuk_design_system_formbuilder/elements/period')

module FormBuilderHelper
  # :nocov:
  # rubocop:disable Metrics/ParameterLists
  def govuk_period_field(attribute_name, hint: {}, legend: {}, caption: {}, widths: {}, maxlength_enabled: false,
                         form_group: {}, **, &block)
    GOVUKDesignSystemFormBuilder::Elements::Period.new(
      self, object_name, attribute_name,
      hint:, legend:, caption:, widths:, maxlength_enabled:, form_group:, **, &block
    ).html
  end

  def continue_button(primary: :continue_button, secondary: :cancel_button,
                      primary_opts: {}, secondary_opts: {})
    submit_button(primary, primary_opts) do
      submit_button(secondary, secondary_opts.merge(secondary: true, name: 'cancel')) if secondary
    end
  end

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.steps.#{i18n_key}"), **opts, &block
  end
  # rubocop:enable Metrics/ParameterLists
  # :nocov:
end
