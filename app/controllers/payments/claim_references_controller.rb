module Payments
  class ClaimReferencesController < ApplicationController
    layout 'payments'

    def edit
      authorize(:payment, :update?)
      @laa_references = Payments::LaaReferenceResults.new.call(:payments)
      @form_object = ClaimReferenceForm.new
    end
  end
end
