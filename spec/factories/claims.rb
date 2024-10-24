FactoryBot.define do
  factory :claim do
    risk { 'low' }
    received_on { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }
    json_schema_version { 1 }
    application_type { 'crm7' }
    data do
      {
        'laa_reference' => laa_reference,
        'ufn' => '123456/001',
        'cntp_order' => nil,
        'cntp_date' => nil,
        'submitter' => submitter,
        'send_by_post' => send_by_post,
        'letters_and_calls' => letters_and_calls,
        'disbursements' => disbursements,
        'work_items' => work_items,
        'defendants' => defendants,
        'supporting_evidences' => supporting_evidences,
        'vat_rate' => vat_rate,
        'firm_office' => firm_office,
        'assigned_counsel' => 'no',
        'unassigned_counsel' => 'yes',
        'agent_instructed' => 'no',
        'remitted_to_magistrate' => 'no',
        'reasons_for_claim' => ['counsel_or_agent_assigned'],
        'supplemental_claim' => 'no',
        'preparation_time' => 'no',
        'work_before' => 'no',
        'work_after' => 'no',
        'work_completed_date' => '2024-01-01',
        'has_disbursements' => 'no',
        'is_other_info' => 'no',
        'youth_court' => 'no',
        'hearing_outcome' => 'CP05',
        'claim_type' => 'non_standard_magistrate',
        'matter_type' => '10',
        'concluded' => 'no',
        'solicitor' => solicitor,
        'answer_equality' => 'no',
        'stage_reached' => 'prog',
        'work_item_pricing' => {
          'waiting' => 45.5,
          'preparation' => 23.2,
          'attendance_without_counsel' => 10.17,
        },
        'cost_summary' => {
          'profit_costs' => {
            'gross_cost' => '120.0',
          },
        },
      }
    end

    transient do
      laa_reference { 'LAA-FHaMVK' }
      submitter do
        {
          'email' => 'provider@example.com',
          'description' => nil
        }
      end
      send_by_post { false }
      supporting_evidences do
        [
          {
            'id' =>  '650c33373ec7a3f8624fdc46',
            'file_name' =>  'Advocacy evidence _ Tom_TC.pdf',
            'content_type' =>  'application/pdf',
            'file_path' =>  '#',
            'created_at' =>  '2023-09-18T14:12:50.825Z',
            'updated_at' =>  '2023-09-18T14:12:50.825Z'
          },
          {
            'id' =>  '650c3337e9fe6be2870684e3',
            'file_name' =>  'Prior Authority_ Psychiatric report_ Tom_TC.png',
            'content_type' =>  'application/pdf',
            'file_path' =>  '#',
            'created_at' =>  '2023-09-18T14:12:50.825Z',
            'updated_at' =>  '2023-09-18T14:12:50.825Z'
          }
        ]
      end
      letters_and_calls do
        [
          {
            'type' => 'letters',
            'count' => 12,
            'uplift' => 95,
            'pricing' => 3.56
          },
          {
            'type' => 'calls',
            'count' => 4,
            'uplift' => 20,
            'pricing' => 3.56
          },
        ]
      end
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-12',
            'disbursement_type' => 'other',
            'total_cost_without_vat' => 100.0
          }
        ]
      end
      work_items do
        [
          {
            'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
            'uplift' => 95,
            'pricing' => 24.0,
            'work_type' => 'waiting',
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'completed_on' => '2022-12-12'
          }
        ]
      end
      defendants do
        [
          {
            'id' =>  '40fb1f88-6dea-4b03-9087-590436b62dd8',
            'maat' =>  'AB12123',
            'main' =>  true,
            'position' =>  1,
            'first_name' =>  'Tracy',
            'last_name' => 'Linklater'
          }
        ]
      end
      vat_rate { 0.2 }
      vat_registered { 'no' }
      firm_office do
        {
          'name' => 'Blundon Solicitor Firm',
          'town' => 'Stoke Newington',
          'postcode' => 'NE10 4AB',
          'previous_id' => nil,
          'account_number' => '121234',
          'address_line_1' => 'Suite 3',
          'address_line_2' => '5 Princess Road',
          'vat_registered' => vat_registered
        }
      end
      solicitor do
        {
          'first_name' => 'Barry',
          'last_name' => 'Scott',
          'reference_number' => '2P314B',
          'contact_first_name' => nil,
          'contact_last_name' => nil,
          'contact_email' => nil,
          'previous_id' => nil
        }
      end
    end

    trait :with_assignment do
      after(:build) do |claim|
        claim.assignments << build(:assignment, submission: claim)
      end
    end

    trait :with_adjustments do
      disbursements do
        [
          {
            'id' => '1234-adj',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'vat_amount_original' => 1.0,
            'total_cost' => 140.0,
            'total_cost_original' => 130.0,
            'total_cost_without_vat' => 130.0,
            'total_cost_without_vat_original' => 100.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-23',
            'disbursement_type' => 'other',
            'adjustment_comment' => 'adjusted up'
          },
          {
            'id' => '5678',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'total_cost' => 140.0,
            'total_cost_without_vat' => 130.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-23',
            'disbursement_type' => 'other'
          }
        ]
      end
      letters_and_calls do
        [
          {
            'type' => 'letters',
            'count' => 12,
            'count_original' => 5,
            'uplift' => 95,
            'uplift_original' => 50,
            'pricing' => 3.56,
            'adjustment_comment' => 'adj'
          },
          {
            'type' => 'calls',
            'count' => 4,
            'count_original' => 5,
            'uplift' => 20,
            'uplift_original' => 50,
            'pricing' => 3.56,
            'adjustment_comment' => 'adj'
          },
        ]
      end
      work_items do
        [
          {
            'id' => '1234-adj',
            'uplift' => 95,
            'uplift_original' => 50,
            'pricing' => 24.0,
            'pricing_original' => 44.0,
            'work_type' => 'waiting',
            'work_type_original' => 'attendance_without_counsel',
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'time_spent_original' => 181,
            'completed_on' => '2022-12-12',
            'adjustment_comment' => 'some comment'
          }
        ]
      end
    end

    trait :increase_adjustment do
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount_original' => 1.0,
            'vat_amount' => 0.0,
            'total_cost_original' => 130.0,
            'total_cost' => 140.0,
            'total_cost_without_vat_original' => 100.0,
            'total_cost_without_vat' => 130.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-23',
            'disbursement_type' => 'other',
            'adjustment_comment' => 'adjusted up'
          }
        ]
      end
    end

    trait :with_reduced_work_item do
      after(:build) do |claim, _context|
        claim.data['work_items'].first['time_spent_original'] = claim.data['work_items'].first['time_spent']
        claim.data['work_items'].first['time_spent'] -= 1
        claim.data['work_items'].first['adjustment_comment'] = 'reducing this work item'
        claim.save!
      end
    end

    trait :decrease_adjustment do
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount_original' => 1.0,
            'vat_amount' => 0.0,
            'total_cost_original' => 130.0,
            'total_cost' => 110.0,
            'total_cost_without_vat_original' => 100.0,
            'total_cost_without_vat' => 80.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-12',
            'disbursement_type' => 'other'
          }
        ]
      end
    end

    trait :legacy_translations do
      data do
        {
          'laa_reference' => laa_reference,
          'ufn' => '123456/001',
          'cntp_order' => nil,
          'cntp_date' => nil,
          'submitter' => submitter,
          'send_by_post' => send_by_post,
          'letters_and_calls' => letters_and_calls,
          'disbursements' => disbursements,
          'work_items' => work_items,
          'defendants' => defendants,
          'supporting_evidences' => supporting_evidences,
          'vat_rate' => vat_rate,
          'firm_office' => firm_office,
          'assigned_counsel' => 'no',
          'unassigned_counsel' => 'yes',
          'agent_instructed' => 'no',
          'remitted_to_magistrate' => 'no',
          'reasons_for_claim' => [
            {
              'value' => 'counsel_or_agent_assigned',
              'en' => 'Counsel or agent assigned'
            }
          ],
          'supplemental_claim' => 'no',
          'preparation_time' => 'no',
          'work_before' => 'no',
          'work_after' => 'no',
          'work_completed_date' => '2024-01-01',
          'has_disbursements' => 'no',
          'is_other_info' => 'no',
          'youth_court' => 'no',
          'hearing_outcome' => {
            'value' => 'CP05',
            'en' => 'CP01 - Arrest warrant issued/adjourned indefinitely'
          },
          'claim_type' => {
            'en' => "Non-standard magistrates' court payment",
            'value' => 'non_standard_magistrate'
          },
          'matter_type' => {
            'value' => '10',
            'en' => '1 - Offences against the person'
          },
          'concluded' => 'no',
          'solicitor' => solicitor,
          'answer_equality' => {
            'value' => 'no',
            'en' => 'No, skip the equality questions'
          },
          'stage_reached' => 'prog',
          'work_item_pricing' => {
            'waiting' => 45.5,
            'preparation' => 23.2,
            'attendance_without_counsel' => 10.17,
          }
        }
      end

      letters_and_calls do
        [
          {
            'type' => {
              'en' => 'Letters',
              'value' => 'letters'
            },
              'count' => 12,
              'uplift' => 95,
              'pricing' => 3.56
          },
          {
            'type' => {
              'en' => 'Calls',
              'value' => 'calls'
            },
              'count' => 4,
              'uplift' => 20,
              'pricing' => 3.56
          },
        ]
      end
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-12',
            'disbursement_type' => {
              'en' => 'Other',
              'value' => 'other'
            },
            'total_cost_without_vat' => 100.0
          }
        ]
      end
      work_items do
        [
          {
            'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
            'uplift' => 95,
            'pricing' => 24.0,
            'work_type' => {
              'en' => 'Waiting',
              'value' => 'waiting'
            },
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'completed_on' => '2022-12-12'
          }
        ]
      end
    end
  end
end
