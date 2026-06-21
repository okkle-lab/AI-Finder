class PagesController < ApplicationController
  def home
    @categories = Category.ordered

    @stats = {
      tools: Tool.visible.count,
      models: ModelVariant.count,
      categories: Rubric::CATEGORIES.size
    }

    @top_rated = Tool.visible.includes(:model_variants).to_a
      .filter_map do |tool|
        score = tool.general_purpose_verdict
        next if score.nil?

        { tool: tool, score: score, model_variant: tool.best_general_purpose_model_variant }
      end
      .sort_by { |entry| -entry[:score] }
      .first(5)

    @recent_posts =
      if FeatureFlags.latest_in_ai?
        Post.published.recent.limit(3)
      else
        Post.none
      end
  end

  def methodology
    @categories = Rubric::CATEGORIES
  end

  def learn
    @topics = LearnTopic.all
  end

  def learn_topic
    @slug = params[:slug]
    @topic = LearnTopic.find(@slug)
    redirect_to(learn_path) if @topic.nil?
  end
end
