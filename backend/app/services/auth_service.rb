class AuthService
  # Sign Up
  def self.signup(params)
    user = nil
    token = nil

    ActiveRecord::Base.transaction do
      user = User.create!(params)
      token = JsonWebToken.encode(user_id: user.id)
    end

    [user, token]
  end

  # Log In
  def self.login(params)
    user = User.find_by(email: params[:email])

    raise StandardError.new("メールまたはパスワードが正しくありません。") unless user&.authenticate(params[:password])

    token = JsonWebToken.encode(user_id: user.id)
    [user, token]
  end
end
