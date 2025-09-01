# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include LaaCrimeFormsCommon::Validators

  primary_abstract_class
end
