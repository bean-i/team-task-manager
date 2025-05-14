class User < ApplicationRecord
    has_secure_password
  
    VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    VALID_PASSWORD_REGEX = /\A(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#%*]).{8,}\z/
  
    validates :first_name, :last_name, presence: true
  
    validates :email,
    presence: true,
    uniqueness: true,
    format: { with: VALID_EMAIL_REGEX, message: "有効なメールアドレス形式で入力してください" }
  
    validates :password,
    format: {
        with: VALID_PASSWORD_REGEX,
        message: "パスワードは8文字以上で、英字・数字・記号（! @ # % * のいずれか）をすべて含めてください"
    },
    if: -> { new_record? || !password.nil? }
end
