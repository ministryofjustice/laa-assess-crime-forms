module Nsm
  class MakeDecisionForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :state
    attribute :grant_comment
    attribute :partial_comment
    attribute :reject_comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :state, inclusion: { in: Claim::ASSESSED_STATES }
    validates :partial_comment, presence: true, if: -> { state == Claim::PART_GRANT }
    validates :reject_comment, presence: true, if: -> { state == Claim::REJECTED }

    validates :state, adjustments_dependant: true

    def save
      return false unless valid?

      previous_state = claim.state
      Claim.transaction do
        claim.data.merge!('status' => state, 'updated_at' => Time.current, 'assessment_comment' => comment)
        claim.update!(state:)
        ::Event::Decision.build(submission: claim,
                                comment: comment,
                                previous_state: previous_state,
                                current_user: current_user)
      end
      NotifyAppStore.perform_later(submission: claim)

      true
    end

    def comment
      case state
      when Claim::GRANTED
        grant_comment
      when Claim::PART_GRANT
        partial_comment
      when Claim::REJECTED
        reject_comment
      end
    end
  end
end
