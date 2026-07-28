require 'rails_helper'
require 'fileutils'

RSpec.describe Payments::Messages::NsmPaymentReport do
  it_behaves_like 'create a payment report', 'nsm'
end
