module SpreeShippingByWeight
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_shipping_by_weight'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end


    config.after_initialize do
      config.spree.calculators.shipping_methods += [
        Spree::Calculator::Shipping::ByWeight,
        Spree::Calculator::Shipping::PriceSackByWeight
      ]
    end
  end
end
