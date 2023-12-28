# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe ClaimFeedbackMailer, type: :mailer do
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:maat_id) { 'AB12123' }
  let(:claim_total) { nil }
  let(:date) { DateTime.now.strftime('%d %B %Y') }
  let(:feedback_url) { 'tbc' }

  describe 'granted' do
    let(:claim) { build(:claim, state: 'granted') }
    let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, maat_id:, claim_total:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'part granted' do
    let(:claim) { build(:claim, state: 'part_grant') }
    let(:feedback_template) { '9df38f19-f76b-42f9-a4e1-da36a65d6aca' }
    let(:part_grant_total) { nil }
    let(:caseworker_decision_explanation) { nil }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:,
       maat_id:, claim_total:, part_grant_total:, caseworker_decision_explanation:,
       date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'rejected' do
    let(:claim) { build(:claim, state: 'rejected') }
    let(:feedback_template) { '7e807120-b661-452c-95a6-1ae46f411cfe' }
    let(:caseworker_decision_explanation) { nil }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, maat_id:, claim_total:,
       caseworker_decision_explanation:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'further information' do
    let(:claim) { build(:claim, state: 'further_information') }
    let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
    let(:date_to_respond_by) { 7.days.from_now.strftime('%d %B %Y') }
    let(:caseworker_information_requested) { nil }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:,
       maat_id:, claim_total:, date_to_respond_by:,
       caseworker_information_requested:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'provider requested' do
    let(:claim) { build(:claim, state: 'provider_requested') }
    let(:feedback_template) { 'bfd28bd8-b9d8-4b18-8ce0-3fb763123573' }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, maat_id:, claim_total:, date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end

  describe 'other status' do
    let(:claim) { build(:claim, state: 'fake') }
    let(:feedback_template) { '9ecdec30-83d7-468d-bec2-cf770a2c9828' }
    let(:date_to_respond_by) { 7.days.from_now.strftime('%d %B %Y') }
    let(:caseworker_information_requested) { nil }
    let(:personalisation) do
      [laa_case_reference:, ufn:, main_defendant_name:, maat_id:,
       claim_total:, date_to_respond_by:, caseworker_information_requested:,
       date:, feedback_url:]
    end

    include_examples 'creates a feedback mailer'
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
