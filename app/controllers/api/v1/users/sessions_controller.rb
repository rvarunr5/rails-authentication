module Api
  module V1
    class Users::SessionsController < Devise::SessionsController
      include RackSessionsFix
      skip_before_action :verify_jti, only: [:create]
      skip_before_action :verify_signed_out_user, only: [:destroy]
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)
        respond_with(resource)
      end

      def destroy
        if current_user
          Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
          respond_with_on_destroy
        else
          respond_with_on_destroy_failure
        end
      end

      private
      def respond_with(resource, _opts = {})
        render json: {
          status: {code: 200, message: 'Logged in successfully.'},
          data: {
            user: UserSerializer.new(resource).as_json,
            token: current_token
          }
        }, status: :ok
      end

      def respond_with_on_destroy
        render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
      end

      def respond_with_on_destroy_failure
        render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
      end

      def current_token
        request.env['warden-jwt_auth.token']
      end
    end
  end
end

# curl -X GET -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJiOWU4Y2Q0Ni00MTgxLTQ5ZWUtODU0Yy0wMmI3ZDA2YzhlYTEiLCJzdWIiOiIxMiIsInNjcCI6InVzZXIiLCJhdWQiOm51bGwsImlhdCI6MTcxOTgwNjU3NCwiZXhwIjoxNzE5ODkyOTc0fQ.LyAFfUF7LpGEdV77cspY24iuuwlsYEpSQs4rBmGpxhk" http://localhost:3000/api/v1/tests