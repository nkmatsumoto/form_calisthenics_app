class WorkoutSessionsController < ApplicationController

  def index
    if params[:workout_id].present?
      @workout = Workout.find(params[:workout_id])
      @workout_sessions = WorkoutSession.where(workout: @workout).order(start_time: :desc, created_at: :desc)
    else
      @workout_sessions = WorkoutSession.order(start_time: :desc, created_at: :desc)
      @workout_sesssion = WorkoutSession.new
    end
  end


  def new
    @workout_session = WorkoutSession.new
  end

  def show
    @workout_session = WorkoutSession.find(params[:id])
    @exercises = @workout_session.exercises
    # need exercise_sets for the exercise and the workout_session
    # create instance(@) for the exercise_sets for the workout_session
    @exercise_sets = @workout_session.exercise_sets
    @workout = @workout_session.workout

    @exercise_sets_grouped = @workout_session.exercise_sets.group_by(&:exercise)

    @exercise_completed = {}
    @workout_session.exercises.each do |exercise|
      @exercise_completed[exercise.name] = false
    end
    @exercise_sets_grouped.each do |exercise, exercise_sets_grouped|
      @exercise_completed[exercise.name] = exercise_sets_grouped.length >= exercise.sets
    end
  end

  def create
    @workout = Workout.find(params[:workout_id])
    @workout_session = WorkoutSession.new
    @workout_session.user = current_user
    @workout_session.workout = @workout
    @workout_session.start_time = DateTime.now


    if @workout_session.save
      redirect_to workout_session_path(@workout_session)
    else
      render root_path
    end
  end

  def view
    @workout_session = WorkoutSession.find(params[:id])
    @exercises = @workout_session.exercises
    # need exercise_sets for the exercise and the workout_session
    # create instance(@) for the exercise_sets for the workout_session
    @exercise_sets = @workout_session.exercise_sets
  end
end
