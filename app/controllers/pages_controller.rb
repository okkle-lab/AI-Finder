class PagesController < ApplicationController
  def home
    @categories = Category.ordered

    @stats = {
      tools: Tool.visible.count,
      models: ModelVariant.count,
      categories: Rubric::CATEGORIES.size
    }
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
