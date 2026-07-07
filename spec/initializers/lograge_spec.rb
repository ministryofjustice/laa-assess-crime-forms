require 'rails_helper'
require 'request_store'

RSpec.describe Lograge do
  after { RequestStore.clear! }

  it 'includes the request id for app log correlation' do
    user = instance_double(User, to_param: 'caseworker-id')
    controller = instance_double(ApplicationController, current_user: user)

    OutboundRequestId.set('rails-request-id')

    expect(Rails.application.config.lograge.custom_payload_method.call(controller)).to eq(
      caseworker_id: 'caseworker-id',
      request_id: 'nscc-assess-rails-request-id'
    )
  end
end
