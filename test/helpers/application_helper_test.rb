require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "search card score flag defaults hidden" do
    refute search_card_score_visible?
  end

  test "search card score flag can be enabled" do
    original = Rails.configuration.x.search.show_card_score
    Rails.configuration.x.search.show_card_score = true

    assert search_card_score_visible?
  ensure
    Rails.configuration.x.search.show_card_score = original
  end

  test "latest in ai flag defaults hidden" do
    refute latest_in_ai_enabled?
  end

  test "latest in ai flag can be enabled" do
    original = Rails.configuration.x.features.latest_in_ai
    Rails.configuration.x.features.latest_in_ai = true

    assert latest_in_ai_enabled?
  ensure
    Rails.configuration.x.features.latest_in_ai = original
  end

  test "model value metrics flag defaults hidden" do
    refute model_value_metrics_enabled?
  end

  test "model value metrics flag can be enabled" do
    original = Rails.configuration.x.features.model_value_metrics
    Rails.configuration.x.features.model_value_metrics = true

    assert model_value_metrics_enabled?
  ensure
    Rails.configuration.x.features.model_value_metrics = original
  end

  test "experimental score categories flag defaults hidden" do
    refute FeatureFlags.experimental_score_categories?
    refute_includes Rubric.categories.keys, "Ease of use"
    refute_includes Rubric.categories.keys, "Image generation"
    refute_includes Rubric.categories.keys, "Privacy & data safety"
    refute_includes Rubric.categories.keys, "Enterprise"
  end

  test "experimental score categories flag can be enabled" do
    original = Rails.configuration.x.features.experimental_score_categories
    Rails.configuration.x.features.experimental_score_categories = true

    assert FeatureFlags.experimental_score_categories?
    assert_includes Rubric.categories.keys, "Ease of use"
    assert_includes Rubric.categories.keys, "Image generation"
    assert_includes Rubric.categories.keys, "Privacy & data safety"
    assert_includes Rubric.categories.keys, "Enterprise"
  ensure
    Rails.configuration.x.features.experimental_score_categories = original
  end

  test "tool verdict commentary stays brief and avoids repeating the headline score" do
    tool = Struct.new(:name).new("SignalFlow")
    tool.define_singleton_method(:overall_verdict) { 7.8 }
    tool.define_singleton_method(:verdict_best_for) { ["Writing", "Coding"] }
    tool.define_singleton_method(:verdict_not_ideal_for) { ["Research-heavy work"] }
    define_singleton_method(:tool_category_breakdown) do |*_args, **_kwargs|
      [{ name: "Writing", score: 8.2 }, { name: "Research", score: 5.4 }]
    end

    commentary = tool_verdict_commentary(tool)
    summary = commentary.join(" ")

    assert_equal 1, commentary.size
    assert_equal 1, summary.scan(/[.!?]/).size
    assert_no_match %r{\b\d+(?:\.\d+)?/10\b}, summary
    assert_no_match /\bscore/i, summary
    assert_no_match /\boverall\b/i, summary
  end
end
