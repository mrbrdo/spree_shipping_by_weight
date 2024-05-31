require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class PriceSackByWeight < ByWeight
      preference :minimal_amount, :decimal, default: 0
      preference :discount_amount, :decimal, default: 0
      preference :discount_countries_iso, :string, default: ''
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      def self.description
        "By Weight With Free Shipping"
      end

      def compute_package(package)
        if discount_applies?(package)
          preferred_discount_amount
        else
          super
        end
      end

      private

      def discount_applies?(package)
        discount_country?(package) &&
        preferred_minimal_amount > 0 &&
        order_total(package) >= preferred_minimal_amount
      end

      def discount_country?(package)
        package.order.ship_address.country.iso.in?(preferred_discount_countries_iso.split(','))
      end

      def order_total(package)
        order = package.order
        return total(package.contents) unless order
        total = order.item_total + order.promo_total
        total += order.savings_plan_total if order.respond_to?(:savings_plan_total)
        total
      end
    end
  end
end
