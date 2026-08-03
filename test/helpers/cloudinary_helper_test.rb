require "test_helper"

class CloudinaryHelperTest < ActionView::TestCase
  include ApplicationHelper
  include MigrationTestHelpers

  setup do
    ActiveStorage::Current.url_options = { host: "www.example.com", protocol: "http" }
  end

  test "exercise set video tag uses the active storage service url" do
    user = create_user!
    workout = create_workout!(user: user)
    exercise = create_exercise!
    session = WorkoutSession.create!(user: user, workout: workout, start_time: Time.current)
    exercise_set = ExerciseSet.create!(exercise: exercise, workout_session: session, reps: 3)
    attach_test_video!(exercise_set)

    html = exercise_set_video_tag(exercise_set, class: "videoreplay")
    assert_includes html, "<video"
    assert_includes html, "videoreplay"
    assert_includes html, "sample.mp4"
    refute_includes html, "/raw/"
  end

  test "exercise set video tag returns nil without attachment" do
    user = create_user!
    workout = create_workout!(user: user)
    exercise = create_exercise!
    session = WorkoutSession.create!(user: user, workout: workout, start_time: Time.current)
    exercise_set = ExerciseSet.create!(exercise: exercise, workout_session: session, reps: 3)

    assert_nil exercise_set_video_tag(exercise_set)
  end
end
