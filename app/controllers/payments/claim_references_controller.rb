module Payments
  class ClaimReferencesController < ApplicationController
    layout 'payments'

    def edit
      authorize(:payment, :update?)
      @form_object = ClaimReferenceForm.new
    end
  end
end
