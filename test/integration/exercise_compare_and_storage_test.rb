require "test_helper"

class ExerciseCompareAndStorageTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user!
    @workout = create_workout!(user: @user)
    @exercise = create_exercise!(name: "Planche Lean", sets: 2)
    ExerciseAssignment.create!(workout: @workout, exercise: @exercise)
    sign_in_as(@user)
  end

  test "compare with one prior session" do
    session = WorkoutSession.create!(user: @user, workout: @workout, start_time: 1.day.ago)
    ExerciseSet.create!(exercise: @exercise, workout_session: session, reps: 4)

    get compare_exercise_path(@exercise)
    assert_response :success
  end

  test "compare with two prior sessions" do
    first = WorkoutSession.create!(user: @user, workout: @workout, start_time: 2.days.ago)
    second = WorkoutSession.create!(user: @user, workout: @workout, start_time: 1.day.ago)
    ExerciseSet.create!(exercise: @exercise, workout_session: first, reps: 3)
    ExerciseSet.create!(exercise: @exercise, workout_session: second, reps: 5)

    get compare_exercise_path(@exercise), params: { first_date: first.id, second_date: second.id }
    assert_response :success
  end

  test "active storage video attachment uses test disk service" do
    session = WorkoutSession.create!(user: @user, workout: @workout, start_time: Time.current)
    exercise_set = ExerciseSet.create!(exercise: @exercise, workout_session: session, reps: 1)
    attach_test_video!(exercise_set)

    assert exercise_set.video.attached?
    assert_equal "video/mp4", exercise_set.video.content_type
    assert_equal "sample.mp4", exercise_set.video.filename.to_s

    get exercise_set_path(exercise_set)
    assert_response :success
  end
end
