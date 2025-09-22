class BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  # Add the ability to read/write attributes without calling their accessor methods.
  # Needed to behave more like an ActiveRecord model, where you can manipulate the
  # DB attributes making use of `self[:attribute]`
  def [](attr_name)
    public_send(attr_name)
  end
end
