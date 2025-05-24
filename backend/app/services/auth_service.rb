class AuthService
  # Sign Up
  def self.signup(params)
    user = nil
    token = nil

    ActiveRecord::Base.transaction do
      if User.exists?(email: params[:email])
        raise StandardError.new("このメールアドレスは既に使用されています。")
      end
      user = User.create!(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email],
        password: params[:password]
      )
      token = JsonWebToken.encode(user_id: user.id)
    end

    [user, token]
  end

  # Log In
  def self.login(params)
    user = User.find_by(email: params[:email])
    raise CustomErrors::AuthenticationError.new("メールアドレスまたはパスワードが正しくありません。") unless user&.authenticate(params[:password])
    token = JsonWebToken.encode(user_id: user.id)
    [user, token]
  end
end
