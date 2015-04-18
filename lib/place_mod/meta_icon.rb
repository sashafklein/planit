module PlaceMod
  class MetaIcon

    attr_reader :meta_category, :categories
    def initialize(meta_category, categories=[])
      @meta_category, @categories = meta_category, categories
    end

    def icon
      return transit_icon if meta_category == 'Transit'
      
      case meta_category
        when 'Area' then 'icomoon icon-map'
        when 'Do' then 'icon-directions-walk'
        when 'Drink' then 'icon-local-bar'
        when 'Food' then 'icon-local-restaurant'
        when 'Help' then 'fa fa-life-ring'
        when 'Money' then 'fa fa-money'
        when 'Other' then 'fa fa-question-circle'
        when 'Relax' then 'fa fa-sun-o'
        when 'See' then 'fa fa-picture-o'
        when 'Shop' then 'fa fa-suitcase'
        when 'Stay' then 'fa fa-home'
        else 'fa fa-question-circle'
      end
    end

    private

    def transit_icon
      if categories.any? # This logic will currently ALWAYS return 'fa fa-subway'
        return 'fa fa-subway'
        return 'fa fa-plane'
        return 'fa fa-car'
        return 'fa fa-bus'
        return 'fa fa-train'
        return 'fa fa-taxi'
      else
        return 'fa fa-bus'
      end
    end
  end
end