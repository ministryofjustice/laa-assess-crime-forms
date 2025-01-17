class IsAUuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || 'is not a valid uuid') unless value.blank? || UUID.validate(value)
  end
end
