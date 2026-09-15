module Authorization
  class RoleSource
    class UnknownAuthority < StandardError; end

    SOURCES = {
      'local' => -> { RoleSources::Local.new },
      'silas' => -> { RoleSources::Silas.new }
    }.freeze

    def self.for(authority)
      SOURCES.fetch(authority.to_s) { raise UnknownAuthority, "Unknown role authority: #{authority}" }.call
    end
  end
end
