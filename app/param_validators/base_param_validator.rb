class BaseParamValidator
  include ActiveModel::Model
  include ActiveModel::Attributes

  def error_summary
    errors.messages.map { |key, value| "Field: #{key}, Errors: #{value}" }.join("\n")
  end
end
