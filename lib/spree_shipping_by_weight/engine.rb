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


    initializer "let the main autoloader ignore this engine's overrides" do
      overrides = root.join("app/overrides")
      Rails.autoloaders.main.ignore(overrides)
    end

    config.after_initialize do
      config.spree.calculators.shipping_methods += [
        Spree::Calculator::Shipping::ByWeight,
        Spree::Calculator::Shipping::PriceSackByWeight
      ]
    end

    config.to_prepare do
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/overrides/*.rb")) do |c|
        load(c)
      end
    end
  end
end
