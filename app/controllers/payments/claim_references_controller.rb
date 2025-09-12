module Payments
  class ClaimReferencesController < ApplicationController
    layout 'payments'

    def edit
      authorize(:payment, :update?)
      @laa_references = AppStoreClient.new.all_laa_references_autocomplete
      @form_object = ClaimReferenceForm.new
    end
  end
end
