require "test_helper"

class ProductionConfigSmokeTest < ActiveSupport::TestCase
  test "production database config uses DATABASE_URL" do
    yaml = File.read(Rails.root.join("config/database.yml"))
    assert_includes yaml, 'url: <%= ENV["DATABASE_URL"] %>'
  end

  test "production cable adapter does not require Redis" do
    cable = YAML.load_file(Rails.root.join("config/cable.yml"))
    assert_equal "async", cable.fetch("production").fetch("adapter")
  end

  test "production mailer uses RENDER_EXTERNAL_HOSTNAME" do
    production_rb = File.read(Rails.root.join("config/environments/production.rb"))
    assert_includes production_rb, 'ENV.fetch("RENDER_EXTERNAL_HOSTNAME"'
    assert_includes production_rb, 'protocol: "https"'
    refute_includes production_rb, "TODO_PUT_YOUR_DOMAIN_HERE"
  end

  test "render blueprint declares free ohio docker service" do
    blueprint = YAML.load_file(Rails.root.join("render.yaml"))
    service = blueprint.fetch("services").find { |entry| entry["name"] == "form-calisthenics-app" }
    assert_equal "web", service["type"]
    assert_equal "docker", service["runtime"]
    assert_equal "free", service["plan"]
    assert_equal "ohio", service["region"]
    assert_equal "master", service["branch"]
    assert_equal "/up", service["healthCheckPath"]
    assert_equal "off", service["autoDeployTrigger"]
  end
end
