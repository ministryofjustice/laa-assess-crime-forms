require 'rails_helper'

RSpec.describe Event::Assignment do
  subject { described_class.build(submission: claim, current_user: current_user) }

  let(:claim) { create(:claim) }
  let(:current_user) { create(:caseworker) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_id: claim.id,
      primary_user_id: current_user.id,
      submission_version: 1,
      event_type: 'Event::Assignment',
    )
  end

  it 'notifies the app store' do
    event = Event.send(:new)
    expect(described_class).to receive(:create).and_return(event)
    expect(NotifyEventAppStore).to receive(:perform_later).with(event:)

    subject
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Claim allocated to caseworker')
  end
end
