require File.dirname(__FILE__) + '/../spec_helper'

describe "searching" do

  before :all do
    DiseaseEvent.delete_all
    HospitalsParticipation.delete_all
    Participation.delete_all
    Event.delete_all
    Person.delete_all
    PersonEntity.delete_all
  end

  after :all do
    Fixtures.reset_cache
  end

  before do
    User.current_user = Factory.create(:user)
  end

  describe "using fuzzy searching on events" do

    it "should return nil, when nothing is searched for" do
      Event.find_by_criteria(:fulltext_terms => '').should == nil
    end

    it "should return nothing, when no results are found" do
      Event.find_by_criteria(:fulltext_terms => 'Davis').should == []
    end

    describe "with actual events" do
      before do
        @james = searchable_event!(:morbidity_event, "James")
        @jaime = searchable_event!(:morbidity_event, "Jaime")
      end

      it "searching for 'james' should return 'James' first" do
        result = Event.find_by_criteria(:fulltext_terms => 'james')
        result.map(&:last_name).should == ["James", "Jaime"]
      end

      it "searching for 'jame' should return 'James' first" do
        result = Event.find_by_criteria(:fulltext_terms => 'jame')
        result.map(&:last_name).should == ["James", "Jaime"]
      end

      it "searching for 'jam' should return 'James' first" do
        result = Event.find_by_criteria(:fulltext_terms => 'jam')
        result.map(&:last_name).should == ["James", "Jaime"]
      end

      it "searching for 'jaime' should return 'Jaime' first" do
        result = Event.find_by_criteria(:fulltext_terms => 'jaime')
        result.map(&:last_name).should == ['Jaime', 'James']
      end

      it "searching for 'jaime ' with a trailing space should not cause an error" do
        result = Event.find_by_criteria(:fulltext_terms => 'jaime ')
        result.map(&:last_name).should == ['Jaime', 'James']
      end
    end
  end

  describe "fuzzy searching on people" do

    it "should return nothing when nothing is searched for" do
      Person.find_all_for_filtered_view(:last_name => '').should == []
    end

    it "should return nothing when search result are empty" do
      Person.find_all_for_filtered_view(:last_name => 'James').should == []
    end

    describe "with people in the db" do
      before do
        @james = searchable_person!('James')
        @jaime = searchable_person!('Jaime')
      end

      it "should return 'James' first" do
        result = Person.find_all_for_filtered_view(:last_name => 'james')
        result.map(&:last_name).should == ["James", "Jaime"]
      end

      it "using 'jame' should return 'James' first" do
        result = Person.find_all_for_filtered_view(:last_name => 'jame')
        result.map(&:last_name).should == ['James', 'Jaime']
      end
    end

  end

  describe "fuzzy searching people for new cmrs" do

    it "should return nothing when nothing is searched for" do
      HumanEvent.find_by_name_and_bdate({}).should == []
    end

    it "should return nothing when search result are empty" do
      HumanEvent.find_by_name_and_bdate(:last_name => 'James').should == []
    end

    it "should not raise an exception if bdate is blank" do
      lambda do
        HumanEvent.find_by_name_and_bdate(:last_name => 'James', :page_size => 50, :page => 1)
      end.should_not raise_error
    end

    describe "with events in the db" do
      before do
        @james = searchable_event!(:morbidity_event, 'James')
        @jaime = searchable_event!(:morbidity_event, 'Jaime')
      end

      it "should return 'James'" do
        result = HumanEvent.find_by_name_and_bdate(:last_name => 'james')
        result.collect(&:last_name).should == ['James', 'Jaime']
      end

      it "using 'jame' should return 'James' first" do
        result = HumanEvent.find_by_name_and_bdate(:last_name => 'jame')
        result.collect(&:last_name).should == ['James', 'Jaime']
      end

      it "should return 'James' using fulltext search" do
        result = HumanEvent.find_by_name_and_bdate(:fulltext_terms => 'james')
        result.collect(&:last_name).should == ['James', 'Jaime']
      end

      it "should return 'James' using fulltext search with trailing whitespace" do
        result = HumanEvent.find_by_name_and_bdate(:fulltext_terms => 'james ')
        result.collect(&:last_name).should == ['James', 'Jaime']
      end

    end

  end

  describe "when excluding deleted people" do
    it 'should not include deleted people by default, only when including the :show_deleted option' do
      last_name = "Deleted-Spec-Guy"

      @person_entity_1 = Factory.create(:person_entity, :person => Factory.create(:person, :last_name => last_name ))
      @person_entity_2 = Factory.create(:person_entity, :person => Factory.create(:person, :last_name => last_name ))
      @deleted_person_entity = Factory.create(:person_entity, :person => Factory.create(:person, :last_name => last_name ), :deleted_at => Time.now)

      Person.find_all_for_filtered_view(:last_name => last_name).should == [@person_entity_1.person, @person_entity_2.person]
      Person.find_all_for_filtered_view(:last_name => last_name).detect { |person| person.person_entity.id == @deleted_person_entity.id }.should be_nil
      Person.find_all_for_filtered_view(:last_name => last_name, :show_deleted => true).size.should == 3
      Person.find_all_for_filtered_view(:last_name => last_name, :show_deleted => true).detect { |person| person.person_entity.id == @deleted_person_entity.id }.should_not be_nil
    end
  end

end


