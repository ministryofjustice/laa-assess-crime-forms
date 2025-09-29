module Decisions
  class BaseDecisionTree
    class InvalidStep < RuntimeError; end
    WRAPPER_CLASS = SimpleDelegator

    class << self
      def rules
        @rules ||= {}
      end

      def from(source)
        raise "Rule already exists for #{source}" if rules[source]

        rules[source] = Rule.new
      end
    end

    attr_reader :form_object, :step_name, :rule

    def initialize(form_object, as:)
      @form_object = form_object
      @step_name = as
      @rule = self.class.rules[as]
    end

    delegate :multi_step_form_session, to: :form_object

    def destination
      return to_route(index: '/payments/requests') unless rule

      detected = nil
      _, destination = rule.destinations.detect do |(condition, _)|
        detected = condition.nil? || wrapped_form_object.instance_exec(&condition.to_proc)
      end

      return to_route(index: '/payments/requests') unless destination

      to_route(resolve_procs(destination, detected))
    end

    private

    def wrapped_form_object
      self.class::WRAPPER_CLASS.new(form_object)
    end

    def resolve_procs(hash_or_proc, detected)
      hash = resolve_proc(hash_or_proc, detected)
      hash.transform_values { |value| resolve_proc(value, detected) }
    end

    def resolve_proc(value, detected)
      if value.respond_to?(:call)
        value.arity.zero? ? wrapped_form_object.instance_exec(&value) : value.call(detected)
      else
        value
      end
    end

    def to_route(hash)
      if hash[:edit]
        { controller: hash.delete(:edit), action: :edit }.merge(hash)
      elsif hash[:show]
        { controller: hash.delete(:show), action: :show }.merge(hash)
      else
        raise "No known verbs found in #{hash.inspect}"
      end
    end
  end
end
