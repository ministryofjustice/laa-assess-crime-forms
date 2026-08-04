require 'rails_helper'
require 'fileutils'

RSpec.describe Payments::Messages::AcPaymentReport do
  it_behaves_like 'create a payment report', 'ac'
end
