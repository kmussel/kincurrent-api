module StreamEventRepository
  extend BaseRepository
  set_model_class Kincurrent::StreamEvent
  
  def self.get_stream_events(stream_id, options={})
    opts = {start_page:1, per_page:20}.merge(options)
    if opts[:startrid]
      selfrom = "(select in('StreamEvent__next') from ##{opts[:startrid]})"
    else
      selfrom = "(select expand(out('event')) from Stream where kin_id = '#{stream_id}')"
    end
    enddepth = ([opts[:start_page], 1].max * opts[:per_page]) 
    startdepth = enddepth - opts[:per_page]
    sql = "select from (traverse in('StreamEvent__next') from #{selfrom} while $depth < #{enddepth}) where $depth >= #{startdepth}"
    cmd = OrientDB::SQLSynchQuery.new(sql).setFetchPlan("out_stream_event_target:1")
    res = Oriented.graph.command(cmd).execute.collect{|m| m.wrapper }
  end

end
