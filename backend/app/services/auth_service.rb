class AuthService
  def self.signup(params)
    user = nil
    token = nil

    ActiveRecord::Base.transaction do
      user = User.create!(params)
      token = JsonWebToken.encode(user_id: user.id)
    end

    [user, token]
  end
end