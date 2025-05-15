class ApplicationController < ActionController::API
    def render_success(message:, data:, status: :ok)
        render json: {
          status: "success",
          message: message,
          data: data
        }, status: status
    end
    
    def render_error(message:, code:, status: :unprocessable_entity)
        render json: {
          status: "error",
          message: message,
          code: code
        }, status: status
    end
end
