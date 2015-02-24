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
        when 'Other' then 'fa fa-globe'
        when 'Relax' then 'icon-drink'
        when 'See' then 'fa fa-university'
        when 'Shop' then 'fa fa-shopping-cart'
        when 'Stay' then 'icon-home'
        else 'fa fa-globe'
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
        return 'fa fa-exchange'
      end
    end
  end
end