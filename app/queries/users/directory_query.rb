module Users
  class DirectoryQuery
    SORT_VALUES = {
      'name' => ->(entry) { [entry.user.first_name.to_s, entry.user.last_name.to_s] },
      'role' => ->(entry) { entry.roles.map { _1.role_type.to_s }.sort },
      'service' => ->(entry) { entry.roles.map { _1.service.to_s }.sort }
    }.freeze

    Entry = Data.define(:user, :roles) do
      delegate :id, :display_name, :email, :deactivated_at, to: :user
    end

    def initialize(role_source:, sort_by:, direction:)
      @role_source = role_source
      @sort_by = sort_by
      @direction = direction
    end

    def call
      entries = User.includes(role_source.preload_association).map do |user|
        Entry.new(user: user, roles: role_source.roles_for(user).to_a)
      end

      entries.sort_by! { sort_value(_1) }
      direction == :desc ? entries.reverse : entries
    end

    private

    attr_reader :role_source, :sort_by, :direction

    def sort_value(entry)
      sorter = SORT_VALUES.fetch(sort_by) { ->(value) { value.public_send(sort_by).to_s } }
      sorter.call(entry)
    end
  end
end
