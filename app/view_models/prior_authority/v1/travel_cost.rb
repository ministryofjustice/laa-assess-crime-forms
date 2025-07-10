module PriorAuthority
  module V1
    class TravelCost < BaseWithAdjustments
      include TravelCostsWithAdjustments

      attribute :id, :string
      attribute :primary, :boolean
      adjustable_attribute :travel_time, :time_period
      adjustable_attribute :travel_cost_per_hour, :decimal, precision: 10, scale: 2
      attribute :travel_cost_reason, :string

      def form_attributes
        attributes.slice('id', 'travel_time', 'travel_cost_per_hour')
      end
    end
  end
end
