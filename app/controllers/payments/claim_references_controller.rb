module Payments
  class ClaimReferencesController < ApplicationController
    layout 'payments'

    def edit
      authorize(:payment, :update?)
      @laa_references = [LaaReference.new("LAA-ABC123", "MOORE"), LaaReference.new("LAA-XYZ321", "SMITH")]
      @form_object = ClaimReferenceForm.new
    end
  end
end
