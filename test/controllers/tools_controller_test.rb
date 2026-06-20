require "test_helper"

class ToolsControllerTest < ActionDispatch::IntegrationTest
  test "model score selector switches category scores" do
    tool = Tool.create!(name: "Selector Test Tool", status: "live")
    low = tool.model_variants.create!(
      name: "Low Model",
      position: 1,
      coding_speed_score: 4,
      coding_accuracy_score: 6
    )
    high = tool.model_variants.create!(
      name: "High Model",
      position: 2,
      coding_speed_score: 9,
      coding_accuracy_score: 9
    )

    get tool_path(tool)

    assert_response :success
    assert_select "turbo-frame#tool_scores"
    assert_select ".model-score-tab-active", "All models"
    assert_select ".model-score-tabs[data-controller='model-score-tabs'][data-model-score-tabs-scope-value='#{tool.id}']"
    assert_select ".model-score-tab-indicator[data-model-score-tabs-target='indicator']"
    assert_select ".model-score-tab[data-model-score-tabs-target='tab']", minimum: 3
    assert_select ".model-score-tab", "Low Model"
    assert_select ".model-score-tab", "High Model"
    assert_select "a.model-score-tab[data-turbo-frame='tool_scores']", "Low Model"
    assert_select ".take-hl-label", false
    assert_select ".cat-bars[data-controller='score-bars']"
    assert_select ".cat-bar-fill[data-score-bars-target='fill'][data-score-bars-key='coding'][data-score-bars-width='90']"
    assert_select ".cat-bar-name", "Coding"
    assert_select ".cat-bar-score", "9"

    get tool_path(tool, model_variant: low.id)

    assert_response :success
    assert_select ".model-score-tab-active", "Low Model"
    assert_select ".cat-bar-name", "Coding"
    assert_select ".cat-bar-score", "5.2"
  end

  test "product score categories keep rubric order instead of score rank" do
    tool = Tool.create!(name: "Stable Order Tool", status: "live")
    tool.model_variants.create!(
      name: "Mixed Model",
      position: 1,
      write_edit_score: 2,
      coding_speed_score: 9,
      coding_accuracy_score: 9
    )

    get tool_path(tool)

    assert_response :success
    assert_select ".cat-bar-name" do |elements|
      assert_equal ["Writing", "Coding"], elements.map { |element| element.text.strip }
    end
  end

  test "unscored selected model does not inherit product category scores" do
    tool = Tool.create!(
      name: "Unscored Variant Tool",
      status: "live",
      prompt_effort_score: 9,
      interface_score: 9,
      learning_curve_score: 9,
      data_retention_score: 8,
      training_on_user_data_score: 8,
      security_certifications_score: 8,
      privacy_controls_score: 8
    )
    unscored = tool.model_variants.create!(name: "Unavailable Model", position: 1)
    tool.model_variants.create!(name: "Scored Model", position: 2, write_edit_score: 8)

    get tool_path(tool, model_variant: unscored.id)

    assert_response :success
    assert_select ".model-score-tab-active", "Unavailable Model"
    assert_select ".cat-breakdown-sub", /Not yet tested/
    assert_select ".cat-bars-shell.cat-bars-shell-unavailable"
    assert_select ".cat-bars[aria-hidden='true']"
    assert_select ".cat-bars-overlay", "Scores currently unavailable"
    assert_select ".cat-bar-name"
    assert_select ".score-empty", false
  end

  test "unavailable model keeps full score backdrop when product has no scores" do
    tool = Tool.create!(name: "Fully Unscored Tool", status: "live")
    unscored = tool.model_variants.create!(name: "Unavailable Model", position: 1)

    get tool_path(tool, model_variant: unscored.id)

    assert_response :success
    assert_select ".cat-bars-shell.cat-bars-shell-unavailable"
    assert_select ".cat-bars-overlay", "Scores currently unavailable"
    assert_select ".cat-bar-name", count: Rubric::CATEGORIES.size
    assert_select ".score-empty", false
  end
end
