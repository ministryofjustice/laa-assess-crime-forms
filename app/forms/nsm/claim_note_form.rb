module Nsm
  class ClaimNoteForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :claim
    attribute :note
    attribute :current_user

    validates :claim, presence: true
    validates :note, presence: true

    def save
      return false unless valid?

      ::Event::Note.build(submission: claim, note: note, current_user: current_user)
      true
    rescue StandardError
      false
    end
  end
end
