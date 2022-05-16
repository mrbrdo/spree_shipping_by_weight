Deface::Override.new(
  virtual_path:  'spree/admin/shared/_calculator_fields',
  name:          'by_weight_calculator_fields',
  replace: 'div.calculator-settings',
  text: <<-HTML

        <div class="calculator-settings">
          <%= f.fields_for :calculator do |calculator_form| %>
            <% object = @object.calculator %>
            <% if object.kind_of?(Spree::Calculator::Shipping::ByWeight) %>
              <% preferences = [] %>
              <% preferences += [:discount_countries_iso, :minimal_amount, :discount_amount] if object.kind_of?(Spree::Calculator::Shipping::PriceSackByWeight) %>
              <% preferences.each do |key| %>
                <%= content_tag(:div, calculator_form.label("preferred_\#{key}", Spree.t(key)) +
                    preference_field_for(calculator_form, "preferred_\#{key}", type: object.preference_type(key)),
                              class: 'form-group', id: [object.class.to_s.parameterize, 'preference', key].join('-')) %>
              <% end %>

              <%= content_tag(:div, calculator_form.label("preferred_currency", Spree.t(:currency)) +
                (calculator_form.select "preferred_currency", currency_options(object.preferences[:currency]), {}, { class: 'form-control select2' }),
                          class: 'form-group', id: [object.class.to_s.parameterize, 'preference', :currency].join('-')) %>

              <% @object.zones.each do |zone| %>
                <div>
                  <h3><%= zone.name %> (<%= zone.description %>):</h3>
                  <%= content_tag(:div, calculator_form.label("preferred_rate_config_\#{zone.id}", Spree.t(:rate_config)) +
                      preference_field_for(calculator_form, "preferred_rate_config_\#{zone.id}", type: :string),
                                class: 'form-group', id: [object.class.to_s.parameterize, 'preference', :rate_config, zone.id].join('-')) %>
                </div>
              <% end %>
            <% else %>
              <%= preference_fields @object.calculator, calculator_form %>
            <% end %>
          <% end %>
        </div>
        HTML
)
