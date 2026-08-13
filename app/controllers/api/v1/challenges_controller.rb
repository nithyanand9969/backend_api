module Api
    module V1
        class ChallengesController < ApplicationController

            before_action:set_challenge,only:[:show,:update,:destroy]

            def index
               
                @challenges =  Challenge.all
                render json: @challenges
            end
            def create
               
                challenge = Challenge.new(challenges_params)
                if challenge.save
                    render json: {
                        status: 'success',
                        message: 'Challenge created successfully',
                        data: challenge
                    }
                else render json:{
                    status: 'error',
                    message: 'Challenge not created',
                }
                            end
                        end
            def show
           
                if @challenge
                    render json: {
                        status: 'success',
                        message: 'Challenge found successfully',
                        data: @challenge
                    }
                else render json:{
                    status: 'error',
                    message: 'Challenge not found',
                    data:@challenge.errors.full_messages
                }
            end
               
            end
            def update
             
                if @challenge.update(challenges_params)
                    render json: {
                        status: 'success',
                        message: 'Challenge updated successfully',
                        data: @challenge
                    }
                else
                    render json: {
                        status: 'error',
                        message: 'Challenge not updated',
                    }
                end
            end
            def destroy
             
                if @challenge
                    @challenge.destroy
                    render json: {
                        status: 'success',
                        message: 'Challenge deleted successfully'
                    }
                else
                    render json: {
                        status: 'error',
                        message: 'Challenge not found'
                    }
                end
            end

           private 

           def challenges_params
                params.require(:challenge).permit(:title,:description,:start_date,:end_date)
           end
           def set_challenge
            @challenge = Challenge.find(params[:id])
           end
        end

    end

end
