class PullUpdates < ApplicationJob
  # queue :default

  def perform(claim)
    last_update = Claim.maximum(:app_store_updated_at)

    json_data = HttpPuller.new.get_all_since(last_update)

    json_data.each do |record|
      save(record['id'], convert_params(record))
    end
  end

  private

  def convert_params(record)
    {
      state: record['application_state'],
      risk: record['application_risk'],
      current_version: record['version',
      app_store_updated_at: record['updated_at'],
    }
  end

  def save(id, params)
    receiver = ReceiveApplicationMetadata.new(id)

    receiver.save(params)
  end
end
