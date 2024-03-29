module Nsm
  module V1
    class LettersAndCallsSummary < BaseViewModel
      attribute :submission

      def summary_row
        [
          rows.sum(&:count).to_s,
          '-',
          NumberTo.pounds(rows.sum(&:provider_requested_amount)),
          '-',
          NumberTo.pounds(rows.sum(&:caseworker_amount))
        ]
      end

      def rows
        @rows ||= BaseViewModel.build(:letter_and_call, submission, 'letters_and_calls')
      end

      def uplift?
        rows.any? { |row| row.uplift&.positive? }
      end
    end
  end
end
