module Spree
  module Api
    module V3
      class ProductSerializer < BaseSerializer
        attributes :id, :name, :description, :slug, :sku, :barcode,
                   :meta_description, :meta_keywords,
                   available_on: :iso8601, created_at: :iso8601, updated_at: :iso8601

        attribute :purchasable do |product|
          product.purchasable?
        end

        attribute :in_stock do |product|
          product.in_stock?
        end

        attribute :backorderable do |product|
          product.backorderable?
        end

        attribute :available do |product|
          product.available?
        end

        attribute :currency do
          currency
        end

        attribute :price do |product|
          price_object(product)&.amount&.to_f
        end

        attribute :display_price do |product|
          price_object(product)&.display_price&.to_s
        end

        attribute :compare_at_price do |product|
          price_object(product)&.compare_at_amount&.to_f
        end

        attribute :display_compare_at_price do |product|
          price = price_object(product)
          next unless price&.compare_at_amount

          Spree::Money.new(price.compare_at_amount, currency: currency).to_s
        end

        attribute :tags do |product|
          product.taggings.map(&:tag)
        end

        # Conditional associations
        many :images,
             resource: Spree.api.v3_storefront_image_serializer,
             if: proc { params[:includes]&.include?('images') } do |product|
          product.variant_images
        end

        many :variants,
             resource: Spree.api.v3_storefront_variant_serializer,
             if: proc { params[:includes]&.include?('variants') }

        one :default_variant,
            resource: Spree.api.v3_storefront_variant_serializer,
            if: proc { params[:includes]&.include?('default_variant') }

        one :master_variant,
            key: :master_variant,
            resource: Spree.api.v3_storefront_variant_serializer,
            if: proc { params[:includes]&.include?('master_variant') } do |product|
          product.master
        end

        many :option_types,
             resource: Spree.api.v3_storefront_option_type_serializer,
             if: proc { params[:includes]&.include?('option_types') }

        many :taxons,
             resource: Spree.api.v3_storefront_taxon_serializer,
             if: proc { params[:includes]&.include?('taxons') } do |product|
          product.taxons_for_store(params[:store])
        end

        private

        def price_object(product)
          @price_object ||= price_for(product.default_variant)
        end
      end
    end
  end
end
