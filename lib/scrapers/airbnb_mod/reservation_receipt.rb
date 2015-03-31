module Scrapers
  module AirbnbMod

    class ReservationReceipt < Airbnb

      def initialize(url, page)
        super(url, page)
      end
      
      def data
        [{
          place: {
            name: name + " (Airbnb)",
            full_address: full_address,
            nearby: nearby,
            categories: ["Bed & Breakfast"],
            phones: phones
          },
          item: {       
            # cost: cost,
            confirmation_code: confirmation_code,
            start_date: start_date,
            end_date: end_date,
            nights: nights,
            confirmation_url: @url,
            host_name: host_name,
          }
        }.merge({ scraper_url: @url })]
      end

      def confirmation_code
        page.css('title').inner_html.split("Code ").try(:last)
      end

      def nights
        p_content( subsection_for('Duration') ).try(:strip)
      end

      def start_date
        ( (p_content( subsection_for("Check In") ).try(:strip)).try(:split, '<br>') ).first
      end

      def end_date
        ( (p_content( subsection_for("Check Out") ).try(:strip)).try(:split, '<br>') ).first
      end

      def nearby
        p_content( subsection_for("Travel Destination") ).strip; rescue nil
      end

      def phones
        return nil unless section = subsection_for('Accommodation Host')
        right_p = section.css('p').find do |p| 
          next unless string = p.inner_html
          val = string.cut(' ', '+')
          val.to_i.to_s == val.strip
        end
        right_p.inner_html.strip
      end

      def host_name
        return nil unless section = subsection_for('Accommodation Host')
        right_p = section.css('p').find do |p| 
          next unless string = p.inner_html
          val = string.cut(' ', '+')
          val.to_i.to_s != val.strip
        end
        right_p.inner_html.strip
      end

      def name
        return nil unless section = section_for("Accommodation Address")
        section.css( 'p.text-lead strong' ).first.try(:inner_html)
      end

      def full_address
        return unless raw_fa
        raw_fa.gsub('<br>', ' ').gsub('</br>', ' ').gsub("</ br>", ' ').strip
      end

      def street_address
        raw_fa ? raw_fa.split("<br>").first : nil
      end

      private

      def raw_fa
        return nil unless section = section_for("Accommodation Address")
        section.css( 'p.text-lead' ).find{ |p| p.css('br').any? }.inner_html
      rescue
        nil
      end

      def section_for(title)
        info_panels.find{ |p| p.inner_html.scan(%r!<h6>\s*#{ title }\s*</h6>!).any? }
      end

      def subsection_for(title, selector='.col-3')
        return nil unless section = section_for(title)
        section.css(selector).find{ |p| p.inner_html.scan(%r!<h6>\s*#{ title }\s*</h6>!).any? }
      end

      def info_panels
        @info_panels ||= page.css( ".panel-body" )
      end

      def p_content(section)
        section.css('p').inner_html
      end
    end
  end
end