class MembersController < ApplicationController
  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    @member = Member.find(params[:id])
    respond_to do |format|
      if @member.update(measure_params)
        format.html 
        format.json { head :no_content } # 204 No Content
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end
  private
  def measure_params
      params.require(:member).permit(:note)
  end



end
