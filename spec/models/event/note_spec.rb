require 'rails_helper'

RSpec.describe Event::Note do
  subject { described_class.build(crime_application:, note:, current_user:) }

  let(:crime_application) { create(:claim) }
  let(:current_user) { create(:caseworker) }
  let(:note) { 'new note' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      crime_application_id: crime_application.id,
      crime_application_version: 1,
      event_type: 'Event::Note',
      primary_user: current_user,
      details: {
        'comment' => 'new note'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Caseworker note')
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('new note')
  end
end
