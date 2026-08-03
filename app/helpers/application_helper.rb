module ApplicationHelper
  # Use Active Storage's Cloudinary service URL so resource type / public id
  # match how the blob was uploaded (video/mp4 vs application/x-matroska).
  def exercise_set_video_tag(exercise_set, **options)
    return unless exercise_set&.video&.attached?

    video_tag(
      exercise_set.video.url,
      {
        controls: false,
        playsinline: true,
        muted: true,
        autoplay: true
      }.merge(options)
    )
  end
end
