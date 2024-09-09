namespace :fixes do
  desc "Amend a contact email address. Typically because user has added a valid but undeliverable address"
  task :update_contact_email, [:id, :new_contact_email] => :environment do |_, args|
    submission = Submission.find(args[:id])

    STDOUT.print "This will update #{submission.data['laa_reference']}'s contact email, \"#{submission.data['solicitor']['contact_email'] || 'nil'}\", to \"#{args[:new_contact_email]}\": Are you sure? (y/n): "
    input = STDIN.gets.strip

    if input.downcase.in?(['yes','y'])
      print 'updating...'
      submission.data['solicitor']['contact_email'] = args[:new_contact_email]
      submission.save!(touch: false)
      puts "#{submission.data['laa_reference']}'s contact email is now #{submission.reload.data['solicitor']['contact_email']}"
    end
  end

  desc "Set LAA reference to correct values"
  task fix_mismatched_references: :environment do
    # retrieved by running app store task fixes:mismatched_references:find 9-09-2024 14:04
    records = [
      {submission_id: '814f8d54-51be-4d6d-ae0c-ed46b3b1c2b0', laa_reference: 'LAA-0SuhmF'},
      {submission_id: '109819f2-0dda-401b-9d5e-e932cbb35092', laa_reference: 'LAA-OxonyX'},
      {submission_id: '329dc047-0a6e-49d3-a96c-11e1512ac0e5', laa_reference: 'LAA-BdsVzu'},
      {submission_id: 'f794ffa1-454e-4e69-be3c-e68a925da962', laa_reference: 'LAA-UHvkT8'},
      {submission_id: '0f704d33-bdfe-43e5-b6a0-953e79b67a1b', laa_reference: 'LAA-36nCj1'},
      {submission_id: '82bb5f76-7c40-4699-b574-4fa548ccdf16', laa_reference: 'LAA-Hu1r19'}
    ]

    records.each do |record|
      id = record['submission_id']
      new_reference = record['laa_reference']
      fix_laa_reference(id, new_reference)
    end
  end

  def fix_laa_reference(id, new_reference)
    submission = Submission.find(id)
    if submission
      application_to_fix = submission.application
      old_reference = application_to_fix['laa_reference']
      application_to_fix['laa_reference'] = new_reference
      submission.application = application_to_fix
      submission.save!(touch: false)
      puts "Submission: #{id} LAA reference updated from #{old_reference} to #{new_reference}"
    else
      puts "Submission: #{id} could not be found"
    end
  end
end
