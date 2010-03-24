class NewCmrSearchResults

  def initialize(results, view)
    @results = results
    @view = view
    publicize_view
  end

  def each
    @results.each do |result|
      yield NewCmrSearchResult.new(result, self)
      @previous_entity_id = result['entity_id']
    end
  end

  def previous_entity_id
    @previous_entity_id
  end

  def view
    @view
  end

  def publicize_view
    @view.class_eval { public :h }
  end

  class NewCmrSearchResult
    include PostgresFu

    def initialize(result, result_set)
      @result = result
      @result_set = result_set
    end

    def css_class
      if event? && deleted?
        'search-inactive tabular'
      else
        'search-active tabular'
      end
    end

    def css_id
      "entity_#{@result['entity_id']}"
    end

    def name
      unless same_as_previous_entity?
        returning "" do |str|
          if @result['first_name'].blank?
            str << view.h(@result['last_name'])
          else
            unless @result['last_name'].blank?
              str << view.h(@result['last_name']) + ', '
            end
            str << view.h(@result['first_name'])
          end
        end
      else
        "<i>&nbsp;&nbsp;#{I18n.t(:same_as_above)}</i>"
      end
    end

    def bdate
      return if @result['birth_date'].blank?
      view.ld(@result['birth_date']) unless same_as_previous_entity?
    end

    def gender
      @result['birth_gender'] unless same_as_previous_entity?
    end

    def event_type
      if event?
        I18n.t(@result['event_type'].underscore)
      else
        "<i>#{I18n.t(:none)}</i>"
      end
    end

    def jurisdiction
      view.i18n_jurisdiction_short_name(@result['jurisdiction_short_name']) if event?
    end

    def event_onset_date
      return if @result['event_onset_date'].blank?
      view.ld(@result['event_onset_date']) if event?
    end

    def disease_name
      if event?
        if can_update? or can_view?
          @result['disease_name']
        else
          I18n.t(:private)
        end
      end
    end

    def links
      if event?
        returning [] do |result|
          result << view.link_to(I18n.t(:edit), edit_path) if can_update?
          result << view.link_to(I18n.t(:show), view_path) if can_view?
        end.join("&nbsp;|&nbsp;")
      end
    end

    def link_to_create_cmr
      unless same_as_previous_entity?
        if can_create?
          view.link_to(I18n.t(:create_cmr_this_person),
                       view.send(:cmrs_path, :from_person => @result['entity_id'], :return => true),
                       :method => :post)
        end
      end
    end

    def deleted?
      not @result['deleted_at'].blank?
    end

    def event?
      not @result['event_id'].blank?
    end

    def same_as_previous_entity?
      @result_set.previous_entity_id == @result['entity_id']
    end

    def can_update?
      User.current_user.is_entitled_to_in?(:update_event, jurisdictions)
    end

    def can_view?
      User.current_user.is_entitled_to_in?(:view_event, jurisdictions)
    end

    def can_create?
      User.current_user.can_create?
    end

    def jurisdictions
      @jurisdictions ||= pg_array(@result['secondary_jurisdictions']) << @result['jurisdiction_entity_id']
    end

    def edit_path
      if morb?
        view.send(:edit_cmr_path, @result['event_id'])
      else
        view.send(:edit_contact_event_path, @result['event_id'])
      end
    end

    def view_path
      if morb?
        view.send(:cmr_path, @result['event_id'])
      else
        view.send(:contact_event_path, @result['event_id'])
      end
    end

    def morb?
      @result['event_type'] == 'MorbidityEvent'
    end

    def view
      @result_set.view
    end

  end
end
