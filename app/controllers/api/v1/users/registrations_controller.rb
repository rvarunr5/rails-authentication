module Api
  module V1
    class Users::RegistrationsController < Devise::RegistrationsController
      include RackSessionsFix
      skip_before_action :verify_jti, only: [:create]
      respond_to :json

      def create
        build_resource(sign_up_params)

        resource.save
        yield resource if block_given?
        if resource.persisted?
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
            respond_with resource
          else
            expire_data_after_sign_in!
            respond_with resource, status: :created
          end
        else
          clean_up_passwords resource
          set_minimum_password_length
          respond_with resource
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: 'Signed up successfully.' },
            data: UserSerializer.new(resource).as_json.merge(token: current_token)
          }
        else
          render json: {
            status: { code: 422, message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
          }, status: :unprocessable_entity
        end
      end

      def current_token
        request.env['warden-jwt_auth.token']
      end
    end
  end
end