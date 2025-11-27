module Payments
  class BaseCard
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper

    include NameConstructable

    CARD_ROWS = [].freeze
    TABLE_ROWS = [].freeze

    attr_reader :session_answers

    def initialize(session_answers)
      @session_answers = session_answers
    end

    def card_rows
      self.class::CARD_ROWS.filter_map do |key|
        value = send(key)

        if value
          {
            key: { text: I18n.t("payments.steps.check_your_answers.edit.#{key}") },
            value: { text: value }
          }
        end
      end
    end
  end
end
