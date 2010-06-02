module LibrarySpecHelper

  class LibraryTree

    def initialize
      @tree_id = FormElement.next_tree_id
      @nodes = []
    end

    def tree_id
      @tree_id
    end

    def last
      @nodes.last
    end

    def first
      @nodes.first
    end

    def library_question(options = {}, &block)
      options.symbolize_keys!
      options[:tree_id] ||= @tree_id
      options[:is_template] ||= true
      question = Factory.build(:question_element, options)
      question.save!
      last.add_child(question) if last
      @nodes.push(question)
      instance_eval(&block) if block_given?
    end

    def library_follow_up(options={}, &block)
      options.symbolize_keys!
      options[:tree_id] ||= @tree_id
      options[:is_template] ||= true
      follow_up = Factory.build(:follow_up_element, options)
      follow_up.save!
      last.add_child(follow_up)
      @nodes.push(follow_up)
      instance_eval(&block) if block_given?
    end

  end

  def library_question(options = {}, &block)
    lib_tree = LibraryTree.new
    lib_tree.library_question(options, &block)
    lib_tree
  end

end
