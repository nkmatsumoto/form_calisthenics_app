ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Fixtures are not used; migration regression tests build records explicitly.
    # fixtures :all
  end
end

module MigrationTestHelpers
  def create_user!(email: "user-#{SecureRandom.hex(4)}@example.com", password: "password123", username: nil)
    username ||= "user_#{SecureRandom.hex(4)}"
    User.create!(email: email, password: password, password_confirmation: password, username: username)
  end

  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  def create_workout!(user:, name: "Test Workout", category: "Skill")
    Workout.create!(user: user, name: name, category: category)
  end

  def create_exercise!(name: "Pull Up", sets: 3, category: "Upper Body")
    Exercise.create!(
      name: name,
      sets: sets,
      category: category,
      lower_reps: 5,
      upper_reps: 10,
      reps: 5,
      rest: 60,
      hold_time: 0,
      duration: 0
    )
  end

  def attach_test_video!(exercise_set)
    exercise_set.video.attach(
      io: File.open(Rails.root.join("test/fixtures/files/sample.mp4")),
      filename: "sample.mp4",
      content_type: "video/mp4"
    )
  end
end

class ActionDispatch::IntegrationTest
  include MigrationTestHelpers
end
