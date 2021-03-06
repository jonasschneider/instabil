module Instabil::Polls
  def self.registered(app)
    app.class_eval do
      
      get '/polls' do
        authenticate!
        @polls = Poll.all
        haml :polls
      end
      
      post '/polls' do
        authenticate!
        @poll = Poll.new params[:poll]
        @poll.creator = current_user
        
        if @poll.save
          redirect "/polls/#{@poll.id}"
        else
          raise "Fail. #{@poll.errors.inspect}"
        end
      end
      
      get '/polls/:id' do
        authenticate!
        @poll = Poll.find params[:id]
        haml :poll
      end
      
      post '/polls/:id/answers' do
        authenticate!
        @poll = Poll.find params[:id]
        @answer = @poll.answers.build params[:answer]
        @answer.creator = current_user
        
        if @answer.save
          redirect "/polls/#{@poll.id}"
        else
          raise "Fail. #{@answer.errors.inspect}"
        end
      end
      
      post '/polls/:id/vote' do
        authenticate!
        @poll = Poll.find params[:id]
        @answer = @poll.answers.find params[:vote][:answer_id]
        @poll.cast_vote! current_user, @answer
        
        flash[:notice] = "Deine Stimme wurde gespeichert."
        redirect "/polls/#{@poll.id}"
      end
      
    end
  end
end