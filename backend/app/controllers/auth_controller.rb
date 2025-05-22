class AuthController < ApplicationController
  # Sign Up
  def signup
    user, token = AuthService.signup(signup_params)

    render_success(
      message: "Sign up succeeded",
      data: {
        user: user
      },
      status: :created,
    )
  rescue => e
    render_error(
      message: e.message,
      status: :unprocessable_entity
    )
  end

  # Log In
  def login
    user = User.find_by(email: login_params[:email])
    
    if user&.authenticate(login_params[:password])
      token = JWT.encode(
        {
          user_id: user.id,
          exp: 24.hours.from_now.to_i
        },
        Rails.application.credentials.secret_key_base,
        'HS256'
      )
      
      render_success(
        message: "ログインに成功しました",
        data: { user: user, token: token }
      )
    else
      raise CustomErrors::AuthenticationError.new('メールアドレスまたはパスワードが正しくありません')
    end
  end

  private

  def signup_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
