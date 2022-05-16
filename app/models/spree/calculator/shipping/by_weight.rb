require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class ByWeight < ShippingCalculator
      include VatPriceCalculation
      preference :currency,        :string,  default: -> { Spree::Config[:currency] }
      preference :rate_config,     :string,  default: -> { "{}" }

      def self.description
        "By Weight"
      end

      after_initialize do
        if calculable.kind_of?(::Spree::ShippingMethod)
          zone_ids = ::Spree::Zone.pluck(:id)
          singleton_class.class_eval do
            zone_ids.each do |zone_id|
              define_method "preferred_rate_config_#{zone_id}" do
                rate_config_for(zone_id)
              end

              define_method "preferred_rate_config_#{zone_id}=" do |value|
                set_rate_config_for(zone_id, value)
              end
            end
          end
        end
      end

      def compute_package(package)
        by_weight_calculator =
          ::Spree::Calculator::ByWeight.new(
            # only need to pass in the default VAT, price is adjusted for correct VAT by Spree
            preferred_tax_rate: default_vat(Spree::TaxCategory.where(is_default: true, deleted_at: nil).first),
            preferred_rate_config: rate_config_for(detect_zone(package)&.id),
            preferred_currency: preferred_currency
          )
        by_weight_calculator.compute_from_weight(package.weight)
      end

      private

      def detect_zone(package)
        order = package.order
        address = order.ship_address || order.bill_address

        Zone.match(address) if address
      end

      def rate_config_for(zone_id)
        if zone_id
          JSON.load(preferred_rate_config)[zone_id.to_s]
        else
          fail "Calculator #{self.id} could not find rate for Zone #{zone_id}"
        end
      end

      def set_rate_config_for(zone_id, new_config)
        config = JSON.load(preferred_rate_config)
        config[zone_id.to_s] = new_config
        self.preferred_rate_config = JSON.dump(config)
      end
    end
  end
end
