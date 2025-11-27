module Nsm
  module V1
    class Decision < BaseViewModel
      attribute :laa_reference, :string
      attribute :submission

      delegate :state, to: :submission
      delegate :id, to: :submission

      def comments
        submission.data['assessment_comment']
      end
    end
  end
end
