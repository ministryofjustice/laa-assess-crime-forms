module Nsm
  class MakeDecisionForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    STATES = [
      GRANTED = 'granted'.freeze,
      PART_GRANT = 'part_grant'.freeze,
      REJECTED = 'rejected'.freeze
    ].freeze

    attribute :state
    attribute :grant_comment
    attribute :partial_comment
    attribute :reject_comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :state, inclusion: { in: STATES }
    validates :partial_comment, presence: true, if: -> { state == PART_GRANT }
    validates :reject_comment, presence: true, if: -> { state == REJECTED }

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
        NotifyAppStore.perform_later(submission: claim)
      end

      true
    end

    def comment
      case state
      when GRANTED
        grant_comment
      when PART_GRANT
        partial_comment
      when REJECTED
        reject_comment
      end
    end
  end
end
