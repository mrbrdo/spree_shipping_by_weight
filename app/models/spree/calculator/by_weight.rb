require_dependency 'spree/calculator'

module Spree
  class Calculator::ByWeight < Calculator
    preference :currency,        :string,  default: -> { Spree::Config[:currency] }
    preference :rate_config,     :string,  default: -> { "2:4,5:5,10:6.10,15:7.10,20:8.2,25:9.6,31.5:10.5" }
    # only need to pass in the default VAT, price is adjusted for correct VAT by Spree
    preference :tax_rate,        :decimal, default: -> { 0.22 }

    def self.description
      "By Weight"
    end

    def self.available?(_object)
      true
    end
    
    def rates
      rates_config = preferred_rate_config.split(',').map { |s|
        d = s.split(':').map(&:to_f)
        [d[0], d[1] * (1 + preferred_tax_rate.to_f)]
      }
    end

    def compute(object)
      compute_from_weight(object.weight)
    end

    def compute_from_weight(weight)
      rates.each do |rate|
        if weight <= rate[0]
          return rate[1]
        end
      end
      fail "Package weight #{weight} too high for ByWeight shipping!"
    end
  end
end
