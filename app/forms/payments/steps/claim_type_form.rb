module Payments
  module Steps
    class ClaimTypeForm < BasePaymentsForm
      attribute :request_type, :string

      validates :request_type, presence: true,
        inclusion: { in: %w[non_standard_mag
                            non_standard_mag_supplemental
                            non_standard_mag_appeal
                            non_standard_mag_amendment
                            assigned_counsel
                            assigned_counsel_appeal
                            assigned_counsel_amendment] }

      def save
        return false unless valid?

        return true unless attribute_changed?(:request_type)

        multi_step_form_session.reset_answers

        attributes.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      end
    end
  end
end
