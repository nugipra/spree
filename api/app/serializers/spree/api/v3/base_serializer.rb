module Spree
  module Api
    module V3
      class BaseSerializer
        include Alba::Resource

        # Context accessors
        def store
          params[:store]
        end

        def currency
          params[:currency]
        end

        def user
          params[:user]
        end

        def locale
          params[:locale]
        end

        def includes
          @includes ||= Array(params[:includes] || [])
        end

        # Check if an association should be included
        def include?(name)
          includes.include?(name.to_s)
        end

        # Get nested includes for a given parent
        def nested_includes_for(parent)
          prefix = "#{parent}."
          includes.select { |i| i.start_with?(prefix) }.map { |i| i.sub(prefix, '') }
        end

        # Build nested params for child serializers
        def nested_params(parent = nil)
          params.merge(includes: parent ? nested_includes_for(parent) : [])
        end

        # Returns price for a variant using full Price List resolution
        def price_for(variant, quantity: nil)
          return nil unless variant.respond_to?(:price_for)

          variant.price_for(
            currency: currency,
            store: store,
            user: user,
            quantity: quantity
          )
        end
      end
    end
  end
end
