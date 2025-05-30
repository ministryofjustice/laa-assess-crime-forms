class BaseViewModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include NameConstructable

  class Builder
    attr_reader :klass, :submission, :rows, :return_array

    def initialize(class_type, submission, *nesting)
      @klass = "#{submission.namespace}::V#{submission.json_schema_version}::#{class_type.to_s.camelcase}".constantize
      @submission = submission
      if nesting.any?
        @rows = submission.data.dig(*nesting)
        @return_array = true
      else
        @rows = [submission.data]
        @return_array = false
      end
    end

    def build
      process do |attributes|
        klass.new(params(attributes))
      end
    end

    private

    def params(attributes)
      submission.attributes
                .merge(submission.data)
                .merge(attributes, 'submission' => submission)
                .slice(*klass.attribute_names)
    end

    def process(&block)
      # :nocov:
      # This change is needed because AdditionalFeesSummary doesn't
      # call `build` the way other summary viewmodels do.
      #
      # We also can't easily cover it without writing a complex test
      # for it, and since we want to hopefully remove all this
      # evantually it's simpler to just not cover it.
      result = rows&.map(&block)
      # :nocov:
      return_array ? result : result[0]
    end
  end

  class << self
    def build(class_type, submission, *)
      Builder.new(class_type, submission, *).build
    end
  end

  private

  delegate :sanitize, :format_in_zone, :format_period, :multiline_text,
           to: :helpers

  def helpers
    ApplicationController.helpers
  end
end
