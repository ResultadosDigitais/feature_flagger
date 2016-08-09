module Rollout
  # Helpers provides view/controller convinient helpers
  #
  # Example:
  # # app/views/home/index.html.erb
  # if rollout?([:email_marketing, :email_flow])
  #   <%= render 'email_flow' %>
  # else
  #   <%= render 'campaigns' %>
  # end
  module Helpers
    def rollout?(feature_key, resource_id = nil)
      feature_key = Array(feature_key)

      if resource_id.nil?
        resource       = rsolv_resource
        resource_id    = resource.id
        feature_key << resource.class.name.parameterize('_')
      end

      Control.rollout?(feature_key, resource_id)
    end

    private

    def rsolv_resource
      method_name = Rollout.configuration[:resource_method]
      public_send(method_name)
    end
  end
end


ActiveSupport.on_load(:action_view) do
  include Rollout::Helpers
end

ActiveSupport.on_load(:action_controller) do
  include Rollout::Helpers
end
