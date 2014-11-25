require_relative 'common_finders'
module BaseRepository
  include CommonFinders::OrientGraph  

  #use set_model_class in sub modules to override this
  def data_class
    ""
  end

  protected

  def set_model_class model_class
    singleton_class.send :define_method, :data_class do
        model_class
    end
  end
end
