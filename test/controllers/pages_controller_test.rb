require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home header search starts hidden while hero search is observable" do
    get root_path

    assert_response :success
    assert_select ".search-form[data-header-search-sentinel]"
    assert_select ".header-search:not(.header-search--available)"
    assert_select ".header-search-button[aria-label='Search AI tools']"
  end

  test "non-home pages show the header search" do
    get learn_path

    assert_response :success
    assert_select ".header-search.header-search--available"
    assert_select ".header-search-input[placeholder='Search AI tools']"
    assert_select ".header-search-button[aria-label='Search AI tools']"
  end

  test "home top rated ranks products and shows the best scoring model" do
    specialist = Tool.create!(name: "Transcription Specialist", status: "live")
    specialist.model_variants.create!(
      name: "Speech Model",
      position: 1,
      transcription_score: 10
    )

    tool = Tool.create!(
      name: "Leaderboard Product",
      provider: "AI Co",
      status: "live",
      prompt_effort_score: 8,
      interface_score: 8,
      learning_curve_score: 8
    )
    tool.model_variants.create!(
      name: "Lower Model",
      position: 1,
      write_edit_score: 6,
      research_fact_checking_score: 6,
      source_quality_score: 6,
      coding_speed_score: 6,
      coding_accuracy_score: 6,
      hallucination_resistance_score: 6,
      consistency_score: 6
    )
    winning_model = tool.model_variants.create!(
      name: "Winning Model",
      position: 2,
      write_edit_score: 8,
      research_fact_checking_score: 8,
      source_quality_score: 8,
      coding_speed_score: 8,
      coding_accuracy_score: 8,
      hallucination_resistance_score: 8,
      consistency_score: 8
    )

    get root_path

    assert_response :success
    assert_select "h2.panel-title", "Top general-purpose products"
    assert_select "a.top-row[href='#{tool_path(tool, model_variant: winning_model.id)}']" do
      assert_select ".top-name", "Leaderboard Product"
      assert_select ".top-meta", /by AI Co/
      assert_select ".top-meta", /Best model: Winning Model/
      assert_select ".top-score", "8"
    end
    assert_select ".top-name", { text: "Transcription Specialist", count: 0 }
    assert_operator specialist.overall_verdict, :>, tool.general_purpose_verdict
    assert_nil specialist.general_purpose_verdict
    assert_select ".top-name", { text: "Winning Model", count: 0 }
    assert_select ".top-meta", { text: /Lower Model/, count: 0 }
  end

  test "home hides latest in ai nav and section when flag is disabled" do
    original = Rails.configuration.x.features.latest_in_ai
    Rails.configuration.x.features.latest_in_ai = false
    Post.create!(title: "Hidden News Item", slug: "hidden-news-item", published_at: Time.current)

    get root_path

    assert_response :success
    assert_select "a.site-nav-link", text: "News", count: 0
    assert_select "h2.panel-title", text: "Latest in AI", count: 0
    refute_includes response.body, "Hidden News Item"
  ensure
    Rails.configuration.x.features.latest_in_ai = original
  end
end
