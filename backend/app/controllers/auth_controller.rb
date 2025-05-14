class AuthController < ApplicationController
    def signup
        user, token = AuthService.signup(signup_params)
        render json: { user: user, token: token }, status: :created
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  
    private
  
    def signup_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
  end  