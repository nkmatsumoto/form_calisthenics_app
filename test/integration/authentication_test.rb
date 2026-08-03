require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "sign in and sign out with existing password hash" do
    user = create_user!(email: "archive@example.com", password: "password123", username: "archive_user")
    assert user.valid_password?("password123")

    sign_in_as(user)
    assert_redirected_to root_path

    follow_redirect!
    assert_response :success

    delete destroy_user_session_path
    assert_response :redirect

    get dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "invalid password is rejected" do
    user = create_user!(email: "badpass@example.com", password: "password123")
    post user_session_path, params: { user: { email: user.email, password: "wrong-password" } }
    assert_response :unprocessable_entity
  end

  test "registration page renders" do
    get new_user_registration_path
    assert_response :success
  end

  test "password reset page renders" do
    get new_user_password_path
    assert_response :success
  end

  test "registration requires username which the stock form does not collect" do
    assert_no_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "newcomer@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
