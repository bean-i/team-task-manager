require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_first_name) { "テスト" }
  let(:valid_last_name)  { "ユーザー" }
  let(:valid_email)      { "test@example.com" }
  let(:valid_password)   { "Test123!" }

  context "サインアップのバリデーション" do
    it "正常な情報で有効である" do
      user = User.new(
        first_name: valid_first_name,
        last_name: valid_last_name,
        email: valid_email,
        password: valid_password
      )
      expect(user).to be_valid
    end

    it "メール形式が無効な場合は無効である" do
      user = User.new(
        first_name: valid_first_name,
        last_name: valid_last_name,
        email: "invalid_email",
        password: valid_password
      )
      expect(user).not_to be_valid
    end

    it "パスワードが8文字未満の場合は無効である" do
      user = User.new(
        first_name: valid_first_name,
        last_name: valid_last_name,
        email: valid_email,
        password: "T1!"
      )
      expect(user).not_to be_valid
    end

    it "パスワードが英字・数字・記号の条件を満たさない場合は無効である" do
      invalid_passwords = ["testtest", "12345678", "Test1234"] # 特殊記号、英字、数字のいずれかが不足
      invalid_passwords.each do |pwd|
        user = User.new(
          first_name: valid_first_name,
          last_name: valid_last_name,
          email: valid_email,
          password: pwd
        )
        expect(user).not_to be_valid
      end
    end
  end
end
