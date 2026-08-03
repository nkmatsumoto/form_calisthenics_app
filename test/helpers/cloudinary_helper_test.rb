require "test_helper"

class CloudinaryHelperTest < ActionView::TestCase
  include CloudinaryHelper

  test "cloudinary helper builds a video tag without live API calls when stubbed" do
    resources = { "resources" => [{ "public_id" => "abc123.mp4" }] }
    original = Cloudinary::Api.method(:resources)

    Cloudinary::Api.define_singleton_method(:resources) { |*| resources }
    begin
      html = cl_video_tag("abc123", resource_type: "raw", controls: false)
      assert_includes html, "abc123"
      assert_match(/video|cloudinary|abc123/, html)
    ensure
      Cloudinary::Api.define_singleton_method(:resources, original)
    end
  end
end
