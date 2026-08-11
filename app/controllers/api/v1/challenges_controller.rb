module Api
    module V1
        class ChallengesController < ApplicationController

            def index
               
                @challenges =  Challenge.all
                render json: @challenges
            end
            def create
                puts "rrrr"
                puts params
                puts 'wwwwww'
                challenge = Challenge.new(title:'welcome',description:'welcome to the challenge',start_date:Date.today,end_date:Date.today+10)
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
                #show single challenge
               
            end
            def update
                #update single challenge
            end
            def destroy
                #delete single challenge
            end

           
        end

    end

end
