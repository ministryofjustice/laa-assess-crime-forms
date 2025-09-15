module Payments
  module Steps
    class ClaimDetailForm < BasePaymentsForm
      attribute :date_received, :string
      attribute :office_code
      attribute :ufn, :string
      attribute :stage
      attribute :defendant_first_name
      attribute :defendant_last_name
      attribute :number_of_defendants
      attribute :number_of_attendances
      attribute :hearing_outcome_code
      attribute :matter_type
      attribute :court
      attribute :youth_court
      attribute :date_work_completed, :string

      def save
        return false unless valid?

        attributes.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      rescue StandardError
        errors.add(:base, :sync_error)
        false
      end
    end
  end
end
