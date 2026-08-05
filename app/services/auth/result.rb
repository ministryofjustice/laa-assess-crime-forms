module Auth
  Result = Data.define(:user, :failure_reason) do
    def success?
      user.present?
    end
  end
end
