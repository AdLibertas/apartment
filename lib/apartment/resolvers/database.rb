require 'apartment/resolvers/abstract'

module Apartment
  module Resolvers
    class Database < Abstract
      def resolve(tenant)
        return init_config if tenant.empty? || init_config[:database] == tenant
        tenant, = tenant if tenant.is_a?(Array)
        tenant_names[tenant] || raise("Unable to resolve tenant #{tenant}")
      end
    end
  end
end
