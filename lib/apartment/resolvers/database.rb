require 'apartment/resolvers/abstract'

module Apartment
  module Resolvers
    class Database < Abstract
      def resolve(tenant)
        tenant_names[tenant]
      end
    end
  end
end
