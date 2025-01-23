module Nsm
  class DashboardsParams < BaseParamValidator
    attribute :nav_select, :string

    validates :nav_select, inclusion: { in: %w[prior_authority nsm search] }, allow_nil: true
  end
end
