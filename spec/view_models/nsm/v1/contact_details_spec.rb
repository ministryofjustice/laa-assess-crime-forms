require 'rails_helper'

RSpec.describe Nsm::V1::ContactDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Contact details')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
            'address_line_1' => '1 Princess Road',
            'address_line_2' => nil
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
          },
          'submitter' => {
            'email' => 'test@test.com'
          }
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe '#data' do
    context 'One line in firm address' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
            'address_line_1' => '1 Princess Road',
            'address_line_2' => nil
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
          },
          'submitter' => {
            'email' => 'test@test.com'
          }
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm account number', value: '121234' },
            { title: 'Firm address', value: '1 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: 'No' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Alternative contact details', value: 'Not provided' },
            { title: 'Provider email address', value: 'test@test.com' }
          ]
        )
      end
    end

    context 'Two lines in firm address' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
            'address_line_1' => 'Suite 3',
            'address_line_2' => '5 Princess Road',
            'vat_registered' => 'no'
          },
          'solicitor' => {
            'first_name' => 'Daniel',
            'last_name' => 'Treaty',
            'reference_number' => '1212333',
          },
          'submitter' => {
            'email' => 'test@test.com'
          }
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm account number', value: '121234' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: 'No' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Alternative contact details', value: 'Not provided' },
            { title: 'Provider email address', value: 'test@test.com' }
          ]
        )
      end
    end

    context 'has contact_email' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
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
          'submitter' => {
            'email' => 'test@test.com'
          }
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm account number', value: '121234' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: 'No' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Alternative contact full name', value: 'Jim Bob' },
            { title: 'Alternative contact email address', value: 'jim@bob.com' },
            { title: 'Provider email address', value: 'test@test.com' }
          ]
        )
      end
    end

    context 'is vat registered' do
      subject = described_class.new(
        {
          'firm_office' => {
            'name' => 'Blundon Solicitor Firm',
            'town' => 'Stoke Newington',
            'postcode' => 'NE10 4AB',
            'account_number' => '121234',
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
          'submitter' => {
            'email' => 'test@test.com'
          },
          'vat_rate' => 0.2
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            { title: 'Firm name', value: 'Blundon Solicitor Firm' },
            { title: 'Firm account number', value: '121234' },
            { title: 'Firm address', value: 'Suite 3<br>5 Princess Road<br>Stoke Newington<br>NE10 4AB' },
            { title: 'Firm VAT registered', value: '20%' },
            { title: 'Solicitor full name', value: 'Daniel Treaty' },
            { title: 'Solicitor reference number', value: '1212333' },
            { title: 'Alternative contact full name', value: 'Jim Bob' },
            { title: 'Alternative contact email address', value: 'jim@bob.com' },
            { title: 'Provider email address', value: 'test@test.com' }
          ]
        )
      end
    end
  end
end
