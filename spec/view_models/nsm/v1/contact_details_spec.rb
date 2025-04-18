require 'rails_helper'

RSpec.describe Nsm::V1::ContactDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Firm details')
    end
  end

  describe '#rows' do
    subject do
      described_class.new(
        'firm_office' => {
          'name' => 'Blundon Solicitor Firm',
          'town' => 'Stoke Newington',
          'postcode' => 'NE10 4AB',
          'address_line_1' => '1 Princess Road',
          'address_line_2' => nil
        },
        'solicitor' => {
          'first_name' => 'Daniel',
          'last_name' => 'Treaty',
          'reference_number' => '1212333',
        },
      )
    end

    it 'has correct structure' do
      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'One line in firm address' do
      subject do
        described_class.new(
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'address_line_1' => '1 Princess Road',
            'address_line_2' => nil
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
          },
        )
      end

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm address', value: '1 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: 'No' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Contact details', value: 'Not provided' },
          ]
        )
      end
    end

    context 'Two lines in firm address' do
      subject do
        described_class.new(
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'address_line_1' => 'Suite 3',
            'address_line_2' => '5 Princess Road',
            'vat_registered' => 'no'
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
          },
        )
      end

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: 'No' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Contact details', value: 'Not provided' },
          ]
        )
      end
    end

    context 'has contact_email' do
      subject do
        described_class.new(
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'address_line_1' => 'Suite 3',
            'address_line_2' => '5 Princess Road',
            'vat_registered' => 'no'
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
            'contact_first_name' => 'Jim',
            'contact_last_name' => 'Bob',
            'contact_email' => 'jim@bob.com'
          },
        )
      end

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: 'No' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Contact full name', value: 'Jim Bob' },
            { title: 'Contact email address', value: 'jim@bob.com' },
          ]
        )
      end
    end

    context 'is vat registered' do
      subject do
        described_class.new(
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'address_line_1' => 'Suite 3',
            'address_line_2' => '5 Princess Road',
            'vat_registered' => 'yes'
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
            'contact_first_name' => 'Jim',
            'contact_last_name' => 'Bob',
            'contact_email' => 'jim@bob.com'
          },
          'submission' => build(:claim),
        )
      end

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: '20%' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Contact full name', value: 'Jim Bob' },
            { title: 'Contact email address', value: 'jim@bob.com' },
          ]
        )
      end
    end
  end
end
