class BaseParamValidator
  include ActiveModel::Model
  include ActiveModel::Attributes
  include LaaCrimeFormsCommon::Validators

  def error_summary
    errors.messages.map { |key, value| "Field: #{key}, Errors: #{value}" }.join("\n")
  end
end
