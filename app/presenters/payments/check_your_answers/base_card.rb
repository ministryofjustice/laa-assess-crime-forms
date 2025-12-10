module Payments
  module CheckYourAnswers
    class BaseCard
      include ActionView::Helpers::TagHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper

      attr_accessor :section, :has_card, :read_only

      def initialize(read_only: false)
        @read_only = read_only
      end

      def title(**)
        I18n.t("payments.steps.check_your_answers.edit.sections.#{section}.title", **)
      end

      def translate_table_key(section, key, **)
        I18n.t("payments.steps.check_your_answers.edit.sections.#{section}.#{key}", **)
      end

      def rows
        row_data.map do |row|
          row_content(row[:head_key], row[:text], row[:head_opts] || {})
        end
      end

      def row_content(head_key, text, head_opts = {})
        heading = head_opts[:text] || translate_table_key(section, head_key, **head_opts)
        {
          key: {
            text: heading
          },
          value: {
            text:
          }
        }
      end

      def custom
        nil
      end

      def change_link_controller_method
        :edit
      end

      def read_only?
        true
      end
    end
  end
end
