require 'rails_helper'

describe 'user:', type: :task do
  let(:user) { create(:caseworker) }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  describe 'deactivate' do
    subject { Rake::Task['user:deactivate'].invoke(user.email) }

    after { Rake::Task['user:deactivate'].reenable }

    let(:expected_output) { "User email: #{user.email} deactivated at 2024-12-19 12:00:00 UTC\n" }

    it 'calls the service' do
      travel_to Time.zone.local(2024, 12, 19, 12) do
        expect { subject }.to output(expected_output).to_stdout
      end
    end
  end
end
