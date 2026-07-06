module Payments
  module CheckYourAnswers
    class NsmClaimDetailsCard < ClaimDetailsCard
      def row_data
        [
          linked_non_standard_magistrate, date_claim_assessed,
          solicitor_office_code, solicitor_firm_name,
          original_submission_month, ufn, stage_reached, defendant_first_name,
          defendant_last_name, number_of_attendances,
          number_of_defendants, hearing_outcome_code,
          matter_type, court, youth_court,
          date_completed,
        ].flatten.compact
      end

      def linked_non_standard_magistrate
        {
          head_key: 'linked_non_standard_magistrate',
          text: linked_ref ||
            I18n.t('payments.steps.check_your_answers.edit.sections.claim_details.no_linked_crm7')
        }
      end

      def date_claim_assessed
        {
          head_key: 'date_claim_assessed',
          text: DateTime.parse(session_answers['date_claim_assessed']).to_fs(:stamp)
        }
      end

      def solicitor_firm_name
        {
          head_key: 'solicitor_firm_name',
          text: session_answers['solicitor_firm_name']
        }
      end

      def solicitor_office_code
        {
          head_key: 'solicitor_office_code',
          text: session_answers['solicitor_office_code']
        }
      end

      def ufn
        {
          head_key: 'ufn',
          text: session_answers['ufn']
        }
      end

      def stage_reached
        {
          head_key: 'stage_reached',
          text: session_answers['stage_reached']
        }
      end

      def defendant_first_name
        {
          head_key: 'defendant_first_name',
          text: session_answers['defendant_first_name']
        }
      end

      def defendant_last_name
        {
          head_key: 'defendant_last_name',
          text: session_answers['defendant_last_name']
        }
      end

      def number_of_attendances
        {
          head_key: 'number_of_attendances',
          text: session_answers['number_of_attendances']
        }
      end

      def number_of_defendants
        {
          head_key: 'number_of_defendants',
          text: session_answers['number_of_defendants']
        }
      end

      def hearing_outcome_code
        {
          head_key: 'hearing_outcome_code',
          text: session_answers['hearing_outcome_code']
        }
      end

      def matter_type
        {
          head_key: 'matter_type',
          text: I18n.t(".laa_crime_forms_common.nsm.matter_type.#{session_answers['matter_type']}")
        }
      end

      def court
        {
          head_key: 'court',
          text: formatted_court_name
        }
      end

      def youth_court
        {
          head_key: 'youth_court',
          text: session_answers['youth_court'] ? I18n.t('helpers.yes_option') : I18n.t('helpers.no_option')
        }
      end

      def date_completed
        return unless session_answers['date_completed']

        {
          head_key: 'date_completed',
          text: DateTime.parse(session_answers['date_completed']).to_fs(:stamp)
        }
      end

      def original_submission_month
        return if session_answers['request_type'] == 'non_standard_magistrate'

        {
          head_key: 'original_submission_date',
          text: month_name(original_submission_date)
        }
      end

      def change_link_controller_path
        if linked_claim?
          'payments/steps/claim_search'
        else
          'payments/steps/office_code_search'
        end
      end

      def change_link_session_id
        params['id']
      end

      def read_only?
        return true if submission?

        false
      end

      private

      def original_submission_date
        Date.new(session_answers['original_submission_year'].to_i, session_answers['original_submission_month'].to_i)
      end

      def submission?
        ActiveModel::Type::Boolean.new.cast(session_answers['submission'])
      end

      def linked_claim?
        session_answers['laa_reference'].present? || session_answers['linked_laa_reference'].present?
      end

      def formatted_court_name
        if session_answers['court_id'] == I18n.t('laa_crime_forms_common.shared.custom')
          "#{session_answers['court_name']} - #{I18n.t('laa_crime_forms_common.shared.na')}"
        else
          "#{session_answers['court_name']} - #{session_answers['court_id']}"
        end
      end

      def linked_ref
        ref = nil
        if ac?
          ref = session_answers['linked_nsm_reference']
        elsif nsm_addition?
          ref = session_answers['linked_laa_reference'] || session_answers['laa_reference']
        elsif nsm_original?
          ref = session_answers['linked_laa_reference']
        # :nocov:
        else
          false
        end
        # :nocov:
        ref.presence
      end

      def ac?
        session_answers['request_type'].in?(%w[assigned_counsel assigned_counsel_appeal assigned_counsel_amendment])
      end

      def nsm_addition?
        session_answers['request_type'].in?(%w[non_standard_mag_amendment non_standard_mag_appeal non_standard_mag_supplemental])
      end

      def nsm_original?
        session_answers['request_type'].in?(%w[non_standard_magistrate breach_of_injunction])
      end
    end
  end
end
