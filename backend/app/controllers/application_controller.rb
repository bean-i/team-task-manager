class ApplicationController < ActionController::API
    include CustomErrors

    rescue_from StandardError, with: :handle_standard_error
    rescue_from CustomErrors::AuthenticationError, with: :handle_authentication_error
    rescue_from CustomErrors::AuthorizationError, with: :handle_authorization_error
    rescue_from CustomErrors::ResourceNotFound, with: :handle_not_found
    rescue_from CustomErrors::ValidationError, with: :handle_validation_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid

    def render_success(message: nil, data: nil, status: :ok)
        response = {
            status: 'success',
            message: message
        }
        response[:data] = data if data.present?
        
        render json: response, status: status
    end
    
    def render_error(message:, status: :unprocessable_entity)
        response = {
            status: 'error',
            message: message,
            error_code: status.to_s
        }
        
        render json: response, status: status
    end

    private

    def authenticate_user!
      token = request.headers['Authorization']&.split(' ')&.last
      raise CustomErrors::AuthenticationError.new('認証が必要です') if token.nil?

      begin
        decoded_token = JWT.decode(
          token, 
          Rails.application.credentials.secret_key_base,
          true, 
          { algorithm: 'HS256' }
        )
        @current_user = User.find(decoded_token[0]['user_id'])
      rescue JWT::ExpiredSignature
        raise CustomErrors::AuthenticationError.new('トークンの有効期限が切れています')
      rescue JWT::DecodeError
        raise CustomErrors::AuthenticationError.new('無効な認証トークンです')
      rescue ActiveRecord::RecordNotFound
        raise CustomErrors::AuthenticationError.new('ユーザーが見つかりません')
      end
    end

    def current_user
      @current_user
    end

    def handle_authentication_error(exception)
      render_error(message: exception.message, status: :unauthorized) # 401
    end

    def handle_authorization_error(exception)
      render_error(message: exception.message, status: :forbidden) # 403
    end

    def handle_not_found(exception)
      render_error(message: exception.message, status: :not_found) # 404
    end

    def handle_validation_error(exception)
      render_error(message: exception.message, status: :unprocessable_entity) # 422
    end

    def handle_record_not_found(exception)
      model_name = exception.model.downcase
      render_error(
        message: "指定された#{model_name}が見つかりません",
        status: :not_found
      )
    end

    def handle_record_invalid(exception)
      render_error(
        message: exception.record.errors.full_messages.join(', '),
        status: :unprocessable_entity
      )
    end

    def handle_standard_error(exception)
      render_error(
        message: exception.message,
        status: :internal_server_error  # 500
      )
    end
end
