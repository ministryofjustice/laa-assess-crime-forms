require 'rails_helper'

RSpec.describe PriorAuthority::V1::ApplicationDetails do
  subject { described_class.new(args) }

  describe '#overview_card' do
    let(:args) do
      { ufn: '123', laa_reference: '456', prison_law: false }
    end
    let(:expected_rows) do
      [{ key: { text: 'LAA reference' }, value: { text: '456' } },
       { key: { text: 'Unique file number' }, value: { text: '123' } },
       { key: { text: 'Prison Law' }, value: { text: 'No' } }]
    end

    it { expect(subject.overview_card.card_rows).to eq(expected_rows) }
  end

  describe '#primary_quote_card' do
    let(:args) do
      {
        service_type: 'accident_reconstruction',
        prior_authority_granted: true,
        quotes: [quote],
        additional_costs: build_list(:additional_cost, 1)
      }
    end
    let(:quote) { build(:primary_quote).with_indifferent_access }
    let(:expected_rows) do
      [{ key: { text: 'Service required' },
        value: { text: 'Accident reconstruction' } },
       { key: { text: 'Service details' },
        value: { text: 'ABC DEF<br>ABC, HIJ, SW1 1AA' } },
       { key: { text: 'Quote upload' },
        value:          { text: '<a href="/prior_authority/downloads/123123123?file_name=test.pdf">test.pdf</a>' } },
       { key: { text: 'Existing prior authority granted' }, value: { text: 'Yes' } }]
    end

    it { expect(subject.primary_quote_card.card_rows).to eq(expected_rows) }

    context 'when additional questions answered' do
      let(:quote) do
        build(:primary_quote, ordered_by_court: true, related_to_post_mortem: false).with_indifferent_access
      end
      let(:expected_rows) do
        [{ key: { text: 'Service required' },
          value: { text: 'Accident reconstruction' } },
         { key: { text: 'Service details' },
           value: { text: 'ABC DEF<br>ABC, HIJ, SW1 1AA' } },
         { key: { text: 'Quote upload' },
           value:          { text: '<a href="/prior_authority/downloads/123123123?file_name=test.pdf">test.pdf</a>' } },
         { key: { text: 'Ordered by court' }, value: { text: 'Yes' } },
         { key: { text: 'Post-mortem' }, value: { text: 'No' } },
         { key: { text: 'Existing prior authority granted' }, value: { text: 'Yes' } }]
      end

      it { expect(subject.primary_quote_card.card_rows).to eq(expected_rows) }
    end
  end

  describe '#reason_why_card' do
    let(:args) do
      { reason_why: 'because', supporting_documents: [{ 'file_name' => 'A', 'file_path' => 'B' }] }
    end
    let(:expected_rows) do
      [{ key: { text: 'Why prior authority is required' },
         value: { text: '<p>because</p>' } },
       { key: { text: 'Supporting documents' },
        value: { text: '<a href="/prior_authority/downloads/B?file_name=A">A</a><br>' } }]
    end

    it { expect(subject.reason_why_card.card_rows).to eq(expected_rows) }
  end

  describe '#alternative_quote_card' do
    let(:args) do
      {
        service_type: 'accident_reconstruction',
        prior_authority_granted: true,
        quotes: [primary_quote.with_indifferent_access, alternative_quote.with_indifferent_access],
        additional_costs: primary_quote_additional_costs,
      }
    end
    let(:primary_quote_additional_costs) { build_list(:additional_cost, 1).map(&:with_indifferent_access) }
    let(:primary_quote) { build(:primary_quote) }
    let(:additional_cost_list) { "Foo\nBar" }
    let(:alternative_quote) { build(:alternative_quote, additional_cost_list:) }
    let(:expected_rows) do
      [{ key: { text: 'Service details' },
        value: { text: 'ABC DEF<br>ABC, HIJ, SW1 1AA' } },
       { key: { text: 'Quote upload' },
        value:          { text: 'None' } },
       { key: { text: 'Additional items' }, value: { text: additional_cost_description } }]
    end
    let(:additional_cost_description) { "<p>Foo\n<br />Bar</p>" }

    it { expect(subject.alternative_quote_cards.first.card_rows).to eq(expected_rows) }

    context 'when there are no additional costs' do
      let(:additional_cost_list) { nil }
      let(:additional_cost_description) { 'None' }

      it { expect(subject.alternative_quote_cards.first.card_rows).to eq(expected_rows) }
    end

    describe '#table_rows' do
      let(:primary_quote) { build(:primary_quote, travel_cost_per_hour: 0) }
      let(:alternative_quote) { build(:alternative_quote, travel_cost_per_hour: 0, additional_cost_total: 0) }
      let(:primary_quote_additional_costs) { [] }
      let(:expected_table_rows) do
        [['Service', '£10.50', '£24.50'],
         ['<strong>Total cost</strong>', '<strong>£10.50</strong>', '<strong>£24.50</strong>']]
      end

      it { expect(subject.alternative_quote_cards.first.table_rows).to eq(expected_table_rows) }
    end
  end

  describe '#client_details_card' do
    let(:args) do
      { defendant: { 'first_name' => 'Sally', 'last_name' => 'Smith', 'date_of_birth' => '2000-01-01' } }
    end
    let(:expected_rows) do
      [{ key: { text: 'Client name' }, value: { text: 'Sally Smith' } },
       { key: { text: 'Date of birth' }, value: { text: '1 January 2000' } }]
    end

    it { expect(subject.client_details_card.card_rows).to eq(expected_rows) }
  end

  describe '#next_hearing_card' do
    let(:args) do
      { next_hearing: true, next_hearing_date: '2025-01-01' }
    end
    let(:expected_rows) do
      [{ key: { text: 'Date of next hearing' }, value: { text: '1 January 2025' } }]
    end

    it { expect(subject.next_hearing_card.card_rows).to eq(expected_rows) }

    context 'when next hearing not specified' do
      let(:args) do
        { next_hearing: false }
      end
      let(:expected_rows) do
        [{ key: { text: 'Date of next hearing' }, value: { text: 'Not known' } }]
      end

      it { expect(subject.next_hearing_card.card_rows).to eq(expected_rows) }
    end
  end

  describe '#case_details_card' do
    let(:args) do
      {
        main_offence_id: main_offence_id,
        custom_main_offence_name: custom_main_offence_name,
        rep_order_date: '2023-02-01',
        client_detained: client_detained,
        prison_id: prison_id,
        custom_prison_name: custom_prison_name,
        subject_to_poca: false,
        defendant: { 'maat' => '123123' }
      }
    end
    let(:main_offence_id) { 'robbery' }
    let(:custom_main_offence_name) { nil }
    let(:client_detained) { false }
    let(:prison_id) { nil }
    let(:custom_prison_name) { nil }
    let(:expected_rows) do
      [{ key: { text: 'Main offence' }, value: { text: 'Robbery' } },
       { key: { text: 'Date of representation order' },
        value: { text: '1 February 2023' } },
       { key: { text: 'MAAT ID number' }, value: { text: '123123' } },
       { key: { text: 'Client detained' }, value: { text: 'No' } },
       { key: { text: 'Subject to POCA' }, value: { text: 'No' } }]
    end

    it { expect(subject.case_details_card.card_rows).to eq(expected_rows) }

    context 'when there is a custom main offence' do
      let(:main_offence_id) { 'custom' }
      let(:custom_main_offence_name) { 'Jaywalking' }
      let(:offence_row) { { key: { text: 'Main offence' }, value: { text: 'Jaywalking' } } }

      it { expect(subject.case_details_card.card_rows).to include(offence_row) }
    end

    context 'when client is detained' do
      let(:client_detained) { true }

      context 'when in a standard prison' do
        let(:prison_id) { 'hmp_albany' }
        let(:prison_row) { { key: { text: 'Where client is detained' }, value: { text: 'HMP Albany' } } }

        it { expect(subject.case_details_card.card_rows).to include(prison_row) }
      end

      context 'when in a custom prison' do
        let(:prison_id) { 'custom' }
        let(:custom_prison_name) { 'HMP Overseas' }
        let(:prison_row) { { key: { text: 'Where client is detained' }, value: { text: 'HMP Overseas' } } }

        it { expect(subject.case_details_card.card_rows).to include(prison_row) }
      end
    end
  end

  describe '#hearing_details_card' do
    let(:args) do
      {
        next_hearing_date: next_hearing_date,
        plea: 'guilty',
        court_type: 'central_criminal_court',
        psychiatric_liaison: false,
        psychiatric_liaison_reason_not: 'reason',
        youth_court: true
      }
    end
    let(:next_hearing_date) { '2023-01-01' }
    let(:expected_rows) do
      [{ key: { text: 'Date of next hearing' }, value: { text: next_hearing_text } },
       { key: { text: 'Likely or actual plea' }, value: { text: 'Guilty' } },
       { key: { text: 'Court type' }, value: { text: 'Central Criminal Court' } },
       { key: { text: 'Psychiatric liaison service accessed' },
        value: { text: 'No' } },
       { key: { text: 'Why not?' }, value: { text: '<p>reason</p>' } },
       { key: { text: 'Youth court matter' }, value: { text: 'Yes' } }]
    end
    let(:next_hearing_text) { '1 January 2023' }

    it { expect(subject.hearing_details_card.card_rows).to eq(expected_rows) }

    context 'when next hearing not specified' do
      let(:next_hearing_date) { nil }
      let(:next_hearing_text) { 'Not known' }

      it { expect(subject.hearing_details_card.card_rows).to eq(expected_rows) }
    end
  end

  describe '#case_contact_card' do
    let(:args) do
      {
        solicitor: { 'contact_first_name' => 'A1', 'contact_last_name' => 'A2', 'contact_email' => 'B' },
        firm_office: { 'name' => 'C', 'account_number' => 'C' }
      }
    end
    let(:expected_rows) do
      [{ key: { text: 'Case contact' }, value: { text: 'A1 A2<br>B' } },
       { key: { text: 'Firm details' }, value: { text: 'C<br>C' } }]
    end

    it { expect(subject.case_contact_card.card_rows).to eq(expected_rows) }
  end

  describe '#section_amended?' do
    let(:args) { { submission: build(:prior_authority_application, data: {}) } }

    it 'returns nil if no usable data' do
      expect(subject.section_amended?('anything')).to be_nil
    end
  end

  describe '#information_cards' do
    let(:args) { { submission: build(:prior_authority_application, data: {}) } }

    it 'returns empty array if no usable data' do
      expect(subject.information_cards).to eq []
    end
  end
end
