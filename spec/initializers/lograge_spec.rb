require 'rails_helper'
require 'request_store'

RSpec.describe Lograge do
  after { RequestStore.clear! }

  it 'includes the request id for app log correlation' do
    user = instance_double(User, to_param: 'caseworker-id')
    controller = instance_double(ApplicationController, current_user: user)

    OutboundRequestId.set('A8B0EB88-EA9A-DCAB-8902-CD521F2D5F51')

    expect(Rails.application.config.lograge.custom_payload_method.call(controller)).to eq(
      caseworker_id: 'caseworker-id',
      request_id: 'nscc-assess-a8b0eb88ea9adcab8902cd521f2d5f51'
    )
  end
end
