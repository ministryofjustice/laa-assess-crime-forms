module PriorAuthority
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :submission
    attribute :current_user
    attribute :updates_needed, array: true
    attribute :further_information_explanation
    attribute :incorrect_information_explanation

    UPDATE_TYPES = [
      FURTHER_INFORMATION = 'further_information'.freeze,
      INCORRECT_INFORMATION = 'incorrect_information'.freeze
    ].freeze

    validate :updates_needed_chosen
    validates :further_information_explanation, presence: true, if: -> { updates_needed.include?(FURTHER_INFORMATION) }
    validates :incorrect_information_explanation, presence: true, if: lambda {
                                                                        updates_needed.include?(INCORRECT_INFORMATION)
                                                                      }

    def summary
      @summary ||= BaseViewModel.build(:application_summary, submission)
    end

    def save
      return false unless valid?

      discard_all_adjustments
      persist_form_values
      update_local_records

      AppStoreClient.new.unassign(submission)
      NotifyAppStore.perform_now(submission:)

      true
    end

    def stash
      persist_form_values

      PriorAuthority::Event::DraftSendBack.build(submission:,
                                                 updates_needed:,
                                                 comments:,
                                                 current_user:)

      AppStoreClient.new.adjust(submission)
    end

    def persist_form_values
      updates_needed.compact_blank! # The checkbox array introduces an empty string value

      submission.data.merge!(attributes.except('submission', 'current_user'))
    end

    def discard_all_adjustments
      app_store_record = AppStoreClient.new.get_submission(submission.id)
      submission.data = app_store_record['application']
    end

    def update_local_records
      # ordering is important here so we can order by date later and have Further info first
      append_explanation(INCORRECT_INFORMATION, incorrect_information_explanation)
      append_explanation(FURTHER_INFORMATION, further_information_explanation)

      submission.data.merge!(
        'resubmission_deadline' => resubmission_deadline,
        'updated_at' => Time.current,
        'status' => PriorAuthorityApplication::SENT_BACK
      )
      submission.state = PriorAuthorityApplication::SENT_BACK
      save_event
    end

    def resubmission_deadline
      LaaCrimeFormsCommon::WorkingDayService
        .call(Rails.application.config.x.rfi.working_day_window)
    end

    def append_explanation(type, explanation)
      return unless updates_needed.include?(type)

      submission.data[type] ||= []

      submission.data[type] << {
        caseworker_id: current_user.id,
        information_requested: explanation,
        requested_at: DateTime.current
      }
    end

    def save_event
      PriorAuthority::Event::SendBack.build(submission:,
                                            updates_needed:,
                                            comments:,
                                            current_user:)
    end

    def comments
      ret = {}
      ret[:further_information] = further_information_explanation if updates_needed.include?(FURTHER_INFORMATION)
      ret[:incorrect_information] = incorrect_information_explanation if updates_needed.include?(INCORRECT_INFORMATION)

      ret
    end

    def updates_needed_chosen
      return if updates_needed.intersect?(UPDATE_TYPES)

      errors.add(:updates_needed, :blank)
    end
  end
end
