module Authorization
  module RoleSources
    class Local < Database
      def initialize
        super(preload_association: :roles)
      end

      def editable?
        true
      end

      def display_name
        nil
      end
    end
  end
end
