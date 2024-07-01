module Response
  extend ActiveSupport::Concern

  def respond_with(resource, _opts={})
    if resource.errors.empty?
      render json: resource, status: :ok
    else
      render json: {errors: resource.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def respond_error(message, status = :unprocessable_entity)
    render json: {error: message}, status: status
  end
end