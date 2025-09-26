module Payments
  module Steps
    class BasePaymentsForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      include LaaCrimeFormsCommon::Validators

      attr_accessor :multi_step_form_session, :form_data

      # Initialize a new form object given an session object, reading and setting
      # the attributes declared in the form object.
      def self.build(form_data, multi_step_form_session:)
        attrs = form_data.slice(*attribute_names).merge!(multi_step_form_session:)
        new(attrs)
      end

      def save
        return false unless valid?

        attributes.each do |k, v|
          multi_step_form_session[k.to_sym] = v
        end

        true
      end

      def to_key
        # Intentionally returns nil so the form builder picks up only
        # the class name to generate the HTML attributes
        nil
      end

      def persisted?
        false
      end

      private

      # :nocov:
      def persist!
        raise 'Subclasses of BaseFormObject need to implement #persist!'
      end
      # :nocov:
    end
  end
end
