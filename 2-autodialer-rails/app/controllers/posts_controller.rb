class PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    if params[:bulk_titles].present?
      create_bulk_posts
    else
      create_single_post
    end
  end

  private

  def create_single_post
    title = post_params[:title]
    extra = post_params[:source_prompt]

    body = AiBlogGenerator.generate(title, extra_details: extra)
    @post = Post.new(
      title: title,
      body: body,
      source_prompt: extra,
      model_used: "openai-gpt-3.5-turbo"
    )

    if @post.save
      redirect_to @post, notice: "Post generated with AI."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create_bulk_posts
    titles = params[:bulk_titles].to_s.lines.map { |l| l.strip }.reject(&:blank?)
    titles.first(10).each do |title|
      body = AiBlogGenerator.generate(title, extra_details: "")
      Post.create!(
        title: title,
        body: body,
        source_prompt: "Bulk generation",
        model_used: "openai-gpt-3.5-turbo"
      )
    end

    redirect_to posts_path, notice: "Bulk AI posts generated."
  end

  def post_params
    params.require(:post).permit(:title, :source_prompt)
  end
end
