require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "customer can sign up with email and username" do
    assert_difference("User.count", 1) do
      post user_registration_path, params: {
        user: {
          username: "new_customer",
          email: "new_customer@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :redirect
  end

  test "admin sign-in uses email and authenticates" do
    admin = AdminUser.create!(email: "staff@example.com", password: "password123")

    get new_admin_user_session_path
    assert_response :success
    assert_select 'input[name="admin_user[email]"]'

    post admin_user_session_path, params: {
      admin_user: { email: admin.email, password: "password123" }
    }

    assert_response :redirect
  end
end
