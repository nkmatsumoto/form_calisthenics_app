module ApplicationHelper
  # Archived Active Storage videos are stored on Cloudinary as the `video`
  # resource type. The old `raw` URLs 404 for these keys.
  def cloudinary_video_resource_type(_blob = nil)
    "video"
  end

  def exercise_set_video_tag(exercise_set, **options)
    return unless exercise_set&.video&.attached?

    cl_video_tag(
      exercise_set.video.key,
      {
        resource_type: cloudinary_video_resource_type(exercise_set.video),
        controls: false,
        playsinline: true,
        muted: true,
        autoplay: true
      }.merge(options)
    )
  end
end
