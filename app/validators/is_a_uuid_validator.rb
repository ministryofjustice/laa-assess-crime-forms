class IsAUuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || "is not a valid uuid") unless UUID.validate(value)
  end
end
