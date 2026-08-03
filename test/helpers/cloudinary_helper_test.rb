require "test_helper"

class CloudinaryHelperTest < ActionView::TestCase
  include CloudinaryHelper
  include ApplicationHelper
  include MigrationTestHelpers

  test "cloudinary helper builds a video tag without live API calls" do
    html = cl_video_tag("abc123", resource_type: "video", controls: false)
    assert_includes html, "abc123"
    assert_match(/video|cloudinary|abc123/, html)
  end

  test "exercise set video tag uses the video resource type" do
    user = create_user!
    workout = create_workout!(user: user)
    exercise = create_exercise!
    session = WorkoutSession.create!(user: user, workout: workout, start_time: Time.current)
    exercise_set = ExerciseSet.create!(exercise: exercise, workout_session: session, reps: 3)
    attach_test_video!(exercise_set)

    html = exercise_set_video_tag(exercise_set, class: "videoreplay")
    assert_includes html, exercise_set.video.key
    assert_includes html, "/video/"
    refute_includes html, "/raw/"
  end
end
