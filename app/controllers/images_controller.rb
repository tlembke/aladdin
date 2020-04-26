class ImagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    image_params[:image].open if image_params[:image].tempfile.closed?

    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.json { render json: { location: @image.image_url }, status: :ok }
      else
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def image_params
    params.require(:image).permit(:image)
  end
end