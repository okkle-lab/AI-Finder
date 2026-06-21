require "test_helper"

class IconHelperTest < ActionView::TestCase
  test "tool logo url prefers explicit logo domain" do
    tool = Tool.new(name: "Whisper", website_url: "https://github.com/openai/whisper", logo_domain: "openai.com")

    assert_equal "https://www.google.com/s2/favicons?domain=openai.com&sz=128", tool_logo_url(tool)
  end

  test "tool logo url falls back to website domain" do
    tool = Tool.new(name: "GitHub Copilot", website_url: "https://github.com/features/copilot")

    assert_equal "https://www.google.com/s2/favicons?domain=github.com&sz=128", tool_logo_url(tool)
  end
end
