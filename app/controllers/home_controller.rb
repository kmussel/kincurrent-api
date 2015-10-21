
module Kincurrent 
		class HomeController < BaseController

          get '/?' do 
            status 404 and return unless current_user
            stream_id = current_user.timeline.kin_id
            results = StreamEventRepository.get_stream_events(stream_id, {startrid: params[:startrid]})
            roar results
          end


	end
end