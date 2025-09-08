module Payments
  class ClaimReferencesController < ApplicationController
    layout 'payments'

    def edit
      authorize(:payment, :update?)
    end
  end
end
