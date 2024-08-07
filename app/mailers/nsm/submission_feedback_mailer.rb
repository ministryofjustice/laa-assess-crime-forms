# frozen_string_literal: true

module Nsm
  class SubmissionFeedbackMailer < NotifyMailer
    def notify(submission)
      feedback_template = feedback_message(submission)
      set_template(feedback_template.template)
      set_personalisation(**feedback_template.contents)
      mail(to: feedback_template.recipient)
    end

    private

    def feedback_message(submission)
      case submission.state
      when 'granted'
        FeedbackMessages::GrantedFeedback.new(submission)
      when 'part_grant'
        FeedbackMessages::PartGrantedFeedback.new(submission)
      when 'rejected'
        FeedbackMessages::RejectedFeedback.new(submission)
      else
        FeedbackMessages::FurtherInformationRequestFeedback.new(submission)
      end
    end
  end
end
